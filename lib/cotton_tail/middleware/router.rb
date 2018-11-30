# frozen_string_literal: true

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

      def handler(route)
        handlers.fetch(route) { raise UndefinedRouteError }
      end

      def response(routing_key, message)
        CottonTail::Response.new handler(routing_key).call(message)
      end
    end
  end
end
