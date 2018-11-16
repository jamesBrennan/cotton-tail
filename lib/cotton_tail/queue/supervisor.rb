# frozen_string_literal: true

require 'fiber'

module CottonTail
  module Queue
    # A supervisor for a single queue
    class Supervisor
      def initialize(queue)
        @queue = queue
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
        @process ||= Reader.spawn(@queue)
      end
    end
  end
end
