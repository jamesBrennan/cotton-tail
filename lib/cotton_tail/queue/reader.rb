# frozen_string_literal: true

require 'fiber'

module CottonTail
  module Queue
    # Queue Reader
    class Reader
      def self.spawn(queue)
        Thread.new { new(queue).start }
      end

      def initialize(queue)
        @queue = queue
      end

      def fiber
        @fiber ||= Fiber.new do
          Fiber.yield @queue.pop until @queue.empty? && @queue.closed?
        end
      end

      def start
        while fiber.alive?
          args = fiber.resume
          stack.call(args) if args
        end
      end

      private

      def stack
        CottonTail.configuration.middleware
      end
    end
  end
end
