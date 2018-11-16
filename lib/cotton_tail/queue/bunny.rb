# frozen_string_literal: true

require 'forwardable'
require 'bunny'

module CottonTail
  module Queue
    # A wrapper around a ::Bunny::Queue that makes it interchangeable with a
    # standard Ruby Queue
    class Bunny < SimpleDelegator
      extend Forwardable

      def self.call(name:, **opts)
        new(name, **opts)
      end

      def initialize(name, manual_ack: false, **opts)
        super ::Queue.new

        @name = name
        @source_opts = opts

        watch_source manual_ack
      end

      def push(args)
        routing_key, message = args
        bind routing_key
        exchange.publish message, routing_key: routing_key
      end

      def pop
        delivery_info, *tail = super
        [delivery_info[:routing_key], delivery_info, *tail]
      end

      private

      def_delegator :'CottonTail.configuration', :connection_args

      def bind(routing_key)
        source.bind('amq.topic', routing_key: routing_key)
      end

      def watch_source(manual_ack)
        source.subscribe(manual_ack: manual_ack) { |*args| self << args }
      end

      def connection
        @connection ||= ::Bunny.new(*connection_args).start
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
