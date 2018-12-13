# frozen_string_literal: true

require 'json'

module CottonTail
  module Middleware
    # Router Middleware
    class Router
      attr_reader :handlers

      def initialize(app, handlers:)
        @app = app
        @handlers = handlers
      end

      def call(message)
        env, req, = message
        @app.call [env, req, response(req.routing_key, message)]
      end

      private

      def route(routing_key)
        CottonTail::Route.new(routing_key)
      end

      def response(routing_key, message)
        CottonTail::Response.new handler(routing_key).call(message)
      end

      def routes(routing_key)
        handlers.keys.select { |route| route.match? routing_key }
      end

      def handler(routing_key)
        route, *conflicts = routes(routing_key)
        raise UndefinedRouteError if route.nil?

        raise RouteConflictError unless conflicts.empty?

        handlers[route]
      end
    end
  end
end
