# frozen_string_literal: true

module CottonTail
  # Register message handlers and dispatch messages to them
  class Router
    def self.call
      new
    end

    def initialize
      @handlers = {}
    end

    def route(key, handler)
      @handlers[key] = handler
    end

    def dispatch(key, *args)
      stack.call @handlers[key].call(*args)
    end

    alias call dispatch

    private

    def stack
      CottonTail.configuration.middleware
    end
  end
end
