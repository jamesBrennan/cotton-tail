# frozen_string_literal: true

require 'forwardable'
require 'bunny'

module Cotton
  module Queue
    # Wrapper for Bunny::Session
    class Connection
      extend Forwardable

      def initialize(url = ENV.fetch('AMQP_ADDRESS', 'amqp://localhost:5672'))
        @url = url
      end

      def chan(prefetch = 1)
        @channels ||= Hash.new do |h, key|
          h[key] = session.create_channel.tap do |ch|
            ch.prefetch(prefetch)
          end
        end
        @channels[prefetch]
      end

      def exchange
        @exchange ||= chan.exchange('amq.topic')
      end

      def session
        @session ||= ::Bunny.new(@url).tap(&:start)
      end

      def_delegators :chan, :ack, :nack, :queue
      def_delegators :exchange, :publish
    end
  end
end
