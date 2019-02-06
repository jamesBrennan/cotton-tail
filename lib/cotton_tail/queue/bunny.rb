# frozen_string_literal: true

require 'forwardable'
require 'bunny'

module CottonTail
  module Queue
    # A wrapper around a ::Bunny::Queue that makes it interchangeable with a
    # standard Ruby Queue
    class Bunny < SimpleDelegator
      def self.call(**opts)
        new(**opts)
      end

      def initialize(name:, connection:, manual_ack: false, **opts)
        super ::Queue.new

        @connection = connection
        @source = build_source(name, opts)

        watch_source manual_ack
      end

      def push(request)
        bind request.routing_key
        exchange.publish request.payload, routing_key: request.routing_key
      end

      def pop
        delivery_info, properties, payload = super
        Request.new(delivery_info, MessageProperties.new(properties.to_h), payload)
      end

      def bind(routing_key)
        source.bind('amq.topic', routing_key: Route.new(routing_key).binding)
      end

      private

      attr_reader :connection, :source

      def nil_opts(opts)
        { exclusive: true }.merge(opts)
      end

      def watch_source(manual_ack)
        source.subscribe(manual_ack: manual_ack) { |*args| self << args }
      end

      def build_source(name, opts)
        return channel.queue('', **nil_opts(opts)) if name.nil?

        channel.queue(name, **opts)
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
