# frozen_string_literal: true

require 'rspec/expectations'
require 'rabbitmq/http/client'
require 'forwardable'

RabbitAPI = Class.new do
  DEFAULT_URL = 'http://guest:guest@localhost:15672'

  class << self
    extend Forwardable

    def_delegators :client, :delete_queue, :list_queue_bindings, :queue_info

    private

    def client
      @client ||= RabbitMQ::HTTP::Client.new(url)
    end

    def url
      @url ||= ENV.fetch('AMQP_MANAGER_URL', DEFAULT_URL)
    end
  end
end

RSpec::Matchers.define :have_bindings do |*bindings|
  routing_keys = lambda do |queue|
    RabbitAPI.list_queue_bindings('/', queue).map(&:routing_key)
  end

  match do |queue|
    expect(routing_keys.call(queue)).to include(*bindings)
  end
end

RSpec::Matchers.define :exist_on_server do
  match do |queue_name|
    true & RabbitAPI.queue_info('/', queue_name)
  rescue Faraday::ResourceNotFound
    false
  end
end

RSpec.shared_context 'rabbitmq_api', shared_context: :metadata do
  def delete_queues(*queues)
    queues.each { |name| delete_queue name }
  end

  def delete_queue(name)
    RabbitAPI.delete_queue('/', name)
  rescue Faraday::ResourceNotFound
    warn "Delete queue skipped: Queue '#{name}' does not exist"
  end
end
