# frozen_string_literal: true

require 'rspec/expectations'
require 'rabbitmq/http/client'
require 'forwardable'

RabbitAPI = Class.new do
  class << self
    extend Forwardable

    def_delegators :client, :delete_queue, :list_queue_bindings, :queue_info
    def_delegators :exchange, :publish

    def bunny
      @bunny ||= Bunny.new(automatically_recover: false, connection_timeout: 10)
                      .tap(&:start)
    end

    private

    ##
    # Lazily initializes and returns the RabbitMQ HTTP client instance.
    #
    # @return [RabbitMQ::HTTP::Client] The HTTP client for interacting with RabbitMQ management API.
    def client
      @client ||= RabbitMQ::HTTP::Client.new(url)
    end

    # @return [String] The URL for the RabbitMQ management API.
    def url
      @url ||= ENV.fetch('AMQP_MANAGER_URL', 'http://guest:guest@localhost:15672')
    end

    ##
    # Returns a Bunny channel for interacting with RabbitMQ, initializing it if necessary.
    #
    # @return [Bunny::Channel] The Bunny channel instance
    def channel
      @channel ||= bunny.create_channel
    end

    def exchange
      @exchange ||= channel.exchange('amq.topic')
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

RSpec.shared_context 'with rabbitmq_api', shared_context: :metadata do
  ##
  # Deletes multiple RabbitMQ queues by name.
  #
  # @param queues [Array<String>] Names of the queues to delete
  def delete_queues(*queues)
    queues.each { |name| delete_queue name }
  end

  def delete_queue(name, log = false)
    RabbitAPI.delete_queue('/', name)
  rescue Faraday::ResourceNotFound
    warn "Delete queue skipped: Queue '#{name}' does not exist" if log
  end

  def publish(*args, **kwargs)
    RabbitAPI.publish(*args, **kwargs)
  end

  def connection
    RabbitAPI.bunny
  end
end
