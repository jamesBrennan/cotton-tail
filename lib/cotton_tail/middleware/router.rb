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
        @app.call [env, req, response(*message)]
      end

      private

      def response(env, req, res)
        routing_key = req.routing_key
        handler = lookup_handler(routing_key)
        route = lookup_route(routing_key)
        req = add_route_params(req, route) if route_params?(route, routing_key)

        CottonTail::Response.new handler.call([env, req, res])
      end

      def routes(routing_key)
        handlers.keys.select { |route| route.match? routing_key }
      end

      def lookup_handler(routing_key)
        handlers[lookup_route(routing_key)]
      end

      def lookup_route(routing_key)
        route, *conflicts = routes(routing_key)
        raise UndefinedRouteError if route.nil?

        raise RouteConflictError unless conflicts.empty?

        route
      end

      def add_route_params(req, route)
        delivery_info, properties, payload = req.to_a
        Request.new(
          delivery_info,
          properties.merge(
            route_params: route.extract_params(req.routing_key)
          ),
          payload
        )
      end

      def route_params?(route, routing_key)
        route.extract_params(routing_key) == {} || true
      end
    end
  end
end
