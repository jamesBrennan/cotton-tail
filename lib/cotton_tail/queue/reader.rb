# frozen_string_literal: true

require 'fiber'

module CottonTail
  module Queue
    # Queue Reader
    class Reader
      def self.spawn(queue, **kwargs)
        Thread.new { new(queue, **kwargs).start }
      end

      def initialize(queue, on_message:)
        @queue = queue
        @on_message = on_message
      end

      def fiber
        @fiber ||= Fiber.new do
          Fiber.yield @queue.pop until @queue.empty? && @queue.closed?
        end
      end

      def start
        while fiber.alive?
          args = fiber.resume
          @on_message.call(*args) if args
        end
      end
    end
  end
end
