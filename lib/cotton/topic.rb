# frozen_string_literal: true

module Cotton
  # Topic DSL
  class Topic
    def initialize(routing_prefix, context)
      @routing_prefix = routing_prefix
      @context = context
    end

    def handle(routing_suffix, klass)
      key = routing_key(routing_suffix)
      @context.instance_eval { handle key, klass }
    end

    private

    def routing_key(suffix)
      [@routing_prefix, suffix].join('.')
    end
  end
end
