# frozen_string_literal: true

require 'fiber'

module Cotton
  module Queue
    # A supervisor for a single queue
    class Supervisor
      def initialize(queue, on_message:)
        @queue = queue
        @on_message = on_message
      end

      def start
        process
      end

      # Start the supervisor, process all pending messages, and then stop
      def run
        @queue.close
        start.tap(&:join)
      end

      private

      # Create or fetch the Fiber that is responsible for reading messages
      # from the queue.
      def reader
        @reader ||= Fiber.new do
          Fiber.yield @queue.pop until @queue.empty? && @queue.closed?
        end
      end

      # Create or fetch the Thread that is responsible for running the
      def process
        @process ||= Thread.new { dispatch_next while running? }
      end

      def running?
        reader.alive?
      end

      def dispatch_next
        args = reader.resume
        @on_message.call(*args) if args
      end
    end
  end
end
