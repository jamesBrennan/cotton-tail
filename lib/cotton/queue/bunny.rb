# frozen_string_literal: true

require 'forwardable'
require 'bunny'

module Cotton
  module Queue
    # A wrapper around a ::Bunny::Queue that makes it interchangeable with a
    # standard Ruby::Queue
    class Bunny
      extend Forwardable

      def self.call(name:, **opts)
        new(name, **opts)
      end

      def initialize(name, prefetch: 1, url: nil, **opts)
        @name = name
        @prefetch = prefetch
        @opts = opts
        @url = url || ENV.fetch('AMQP_ADDRESS', 'amqp://localhost:5672')
        @closed = false
        queue
      end

      def bind(routing_key)
        queue.bind('amq.topic', routing_key: routing_key)
      end

      def push(args)
        routing_key, message = args
        exchange.publish message, routing_key: routing_key
      end

      def close
        @closed = true
      end

      def closed?
        @closed
      end

      def empty?
        queue.message_count.zero?
      end

      def pop
        return if empty?

        delivery_info, *tail = queue.pop
        [delivery_info[:routing_key], delivery_info] + tail
      end

      private

      def exchange
        @exchange ||= chan.exchange('amq.topic')
      end

      def conn
        @conn ||= ::Bunny.new(@url).tap(&:start)
      end

      def chan
        @chan ||= conn.create_channel.tap do |ch|
          ch.prefetch(@prefetch)
        end
      end

      def queue
        @queue ||= chan.queue(@name, **@opts)
      end
    end
  end
end
