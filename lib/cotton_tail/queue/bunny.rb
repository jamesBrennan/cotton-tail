# frozen_string_literal: true

module CottonTail
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
        @conn = conn
        @queue = conn.queue(@name, **opts)
        @messages = ::Queue.new
        @queue.subscribe(manual_ack: manual_ack) { |*args| @messages << args }
      end

      def bind(routing_key)
        @queue.bind('amq.topic', routing_key: routing_key)
      end

      def push(args)
        routing_key, message = args
        @conn.publish message, routing_key: routing_key
      end

      def close
        @messages.close
      end

      def closed?
        @messages.closed?
      end

      def empty?
        @messages.empty?
      end

      def pop
        delivery_info, *tail = @messages.pop
        [delivery_info[:routing_key], delivery_info, *tail, conn: @conn]
      end
    end
  end
end
