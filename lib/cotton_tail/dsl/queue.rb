# frozen_string_literal: true

module CottonTail
  module DSL
    # Queue DSL
    class Queue
      def initialize(name, queue, context)
        @name = name
        @queue = queue
        @context = context
      end

      def handle(key, handler = nil, &block)
        bind(key)
        @context.handle(key, handler, &block)
      end

      def topic(routing_prefix, &block)
        topic = Topic.new(routing_prefix, self)
        topic.instance_eval(&block)
      end

      private

      def bind(key)
        return unless @queue.respond_to?(:bind)

        @queue.bind key
      end
    end
  end
end
