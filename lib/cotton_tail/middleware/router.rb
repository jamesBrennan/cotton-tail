# frozen_string_literal: true

module CottonTail
  module Middleware
    # Router Middleware
    class Router
      def initialize(app)
        @app = app
      end

      def call(message)
        route, *args = message
        @app.call handler(route).call(*args)
      end

      private

      def handler(route)
        handlers.fetch(route) { raise UndefinedRouteError }
      end

      def handlers
        CottonTail.application.routes.handlers
      end
    end
  end
end
