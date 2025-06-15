# frozen_string_literal: true

module CottonTail
  module Queue
    # A supervisor for a single queue
    class Supervisor
      def initialize(queue, app:)
        @queue = queue
        @app = app
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
        @process ||= Reader.spawn(@queue, app: @app)
      end
    end
  end
end
