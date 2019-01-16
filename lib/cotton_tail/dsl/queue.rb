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

      def handle(pattern, handler = nil, &block)
        bind pattern
        @context.handle(pattern, handler, &block)
      end

      def topic(routing_prefix, &block)
        topic = Topic.new(routing_prefix, self)
        topic.instance_eval(&block)
      end

      def bind(pattern)
        return unless @queue.respond_to?(:bind)

        @queue.bind pattern
      end
    end
  end
end
