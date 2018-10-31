# frozen_string_literal: true

require 'fiber'

module CottonTail
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

      def running?
        true & process.status
      end

      private

      def process
        @process ||= Reader.spawn(@queue, on_message: @on_message)
      end
    end
  end
end
