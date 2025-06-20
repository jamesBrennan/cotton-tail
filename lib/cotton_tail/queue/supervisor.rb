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
        thread
      end

      # Start the supervisor, process all pending messages, and then stop
      def run
        @queue.close
        start.tap(&:join)
      end

      def running?
        thread.alive?
      end

      private

      def thread
        @thread ||= Reader.spawn(@queue, app: @app)
      end
    end
  end
end
