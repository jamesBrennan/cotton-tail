# frozen_string_literal: true

module Cotton
  module Queue
    # A wrapper around a ::Bunny::Queue that makes it interchangeable with a
    # standard Ruby::Queue
    class Bunny
      def self.call(name:, **opts)
        new(name, **opts)
      end

      def initialize(name, conn: Connection.new, prefetch: 1, manual_ack: false, **opts)
        @name = name
        @prefetch = prefetch
        @manual_ack = manual_ack
        @conn = conn
        @closed = false
        @queue = conn.queue(@name, **opts)
      end

      def bind(routing_key)
        @queue.bind('amq.topic', routing_key: routing_key)
      end

      def push(args)
        routing_key, message = args
        @conn.publish message, routing_key: routing_key
      end

      def close
        @closed = true
      end

      def closed?
        @closed
      end

      def empty?
        @queue.message_count.zero?
      end

      def pop
        return if empty?

        delivery_info, *tail = @queue.pop(manual_ack: @manual_ack)
        [delivery_info[:routing_key], delivery_info, *tail, conn: @conn]
      end
    end
  end
end
