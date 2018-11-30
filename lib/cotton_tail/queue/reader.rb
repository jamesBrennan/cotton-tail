# frozen_string_literal: true

require 'fiber'

module CottonTail
  module Queue
    # Queue Reader
    class Reader
      def self.spawn(queue, **kwargs)
        Thread.new { new(queue, **kwargs).start }
      end

      def initialize(queue, app:)
        @queue = queue
        @app = app
      end

      def fiber
        @fiber ||= Fiber.new do
          Fiber.yield @queue.pop until @queue.empty? && @queue.closed?
        end
      end

      def start
        call_next while fiber.alive?
      end

      private

      def call_next
        request = fiber.resume
        middleware.call([env, request, Response.new]) if request
      end

      def middleware
        @app.config.middleware
      end

      def env
        @app.env
      end
    end
  end
end
