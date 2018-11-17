# frozen_string_literal: true

module CottonTail
  module Middleware
    # Router Middleware
    class Router
      def initialize(app)
        @app = app
      end

      def call(request)
        message = parse(request)
        @app.call handler(message.routing_key).call(request)
      end

      private

      def handler(route)
        handlers.fetch(route) { raise UndefinedRouteError }
      end

      def handlers
        CottonTail.application.routes.handlers
      end

      def parse(msg)
        Message.new(*msg)
      end
    end
  end
end
