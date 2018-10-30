# frozen_string_literal: true

module Cotton
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
      @handlers[key].call(*args)
    end
  end
end
