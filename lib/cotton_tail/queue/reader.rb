# frozen_string_literal: true

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
          loop do
            msg = begin
              # Non-blocking pop; raises ThreadError when queue is empty
              @queue.pop(true)
            rescue ThreadError
              nil
            end

            Fiber.yield msg if msg

            # Exit once producer has signalled no more messages
            break if @queue.closed? && @queue.empty?

            # Back-off a little to avoid busy-loop when idle
            sleep 0.01 unless msg
          end
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
