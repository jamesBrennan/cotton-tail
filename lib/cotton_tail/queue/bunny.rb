# frozen_string_literal: true

require 'forwardable'
require 'bunny'

module CottonTail
  module Queue
    # A wrapper around a ::Bunny::Queue that makes it interchangeable with a
    # standard Ruby Queue
    class Bunny < SimpleDelegator
      extend Forwardable

      def self.call(**opts)
        new(**opts)
      end

      def initialize(name:, connection:, manual_ack: false, **opts)
        super ::Queue.new

        @name = name
        @source_opts = opts
        @connection = connection

        watch_source manual_ack
      end

      def push(request)
        bind request.routing_key
        exchange.publish request.payload, routing_key: request.routing_key
      end

      def pop
        Request.new(*super)
      end

      def bind(routing_key)
        source.bind('amq.topic', routing_key: routing_key)
      end

      private

      attr_reader :connection

      def watch_source(manual_ack)
        source.subscribe(manual_ack: manual_ack) { |*args| self << args }
      end

      def source
        @source ||= channel.queue(@name, **@source_opts)
      end

      def channel
        @channel ||= connection.create_channel
      end

      def exchange
        @exchange ||= channel.exchange('amq.topic')
      end
    end
  end
end
