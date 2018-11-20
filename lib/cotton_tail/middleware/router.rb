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
        request.shift
        request.unshift message.app.env
        @app.call handler(message.app, message.routing_key).call(request)
      end

      private

      def handler(app, route)
        handlers(app).fetch(route) { raise UndefinedRouteError }
      end

      def parse(msg)
        Message.new(*msg)
      end

      def handlers(app)
        app.routes.handlers
      end
    end
  end
end
