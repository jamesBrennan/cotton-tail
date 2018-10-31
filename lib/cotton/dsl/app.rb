# frozen_string_literal: true

module Cotton
  module DSL
    # This is the top level DSL for defining the bindings and message routing of
    # a cotton App
    class App
      attr_reader :queues

      def initialize(queue_strategy:, routing_strategy:)
        @queue_strategy = queue_strategy
        @routing_strategy = routing_strategy
        @queues = {}
      end

      # Define a new queue
      def queue(name, **opts, &block)
        @queue_strategy.call(name: name, **opts).tap do |queue_instance|
          @queues[name] = queue_instance
          queue_dsl = Queue.new(name, queue_instance, self)
          queue_dsl.instance_eval(&block) if block_given?
        end
      end

      # Creates a scope for nested bindings
      #
      # @example
      #   topic 'some.resource' do
      #     handle 'event.updated', lambda do
      #       puts "I'm bound to some.resource.event.updated"
      #     end
      #   end
      #
      # @param [String] routing_prefix The first part of the routing_key
      def topic(routing_prefix, &block)
        topic = Topic.new(routing_prefix, self)
        topic.instance_eval(&block)
      end

      def handle(key, handler = nil, &block)
        handler ||= block
        router.route key, handler
      end

      def router
        @router ||= @routing_strategy.call
      end
    end
  end
end
