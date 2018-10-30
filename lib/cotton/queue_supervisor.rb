# frozen_string_literal: true

require 'fiber'

module Cotton
  # A supervisor for a single queue
  class QueueSupervisor
    def initialize(queue, router:)
      @queue = queue
      @router = router
      @status = :initialized
    end

    def start
      @status = :started
      process
    end

    # Start the supervisor, process all pending messages, and stop
    def run
      @queue.close
      start
    end

    private

    def reader
      @reader ||= Fiber.new do
        Fiber.yield @queue.pop until @queue.empty? && @queue.closed?
      end
    end

    def process
      dispatch_next while running?
    end

    def running?
      @status == :started && reader.alive?
    end

    def dispatch_next
      args = reader.resume
      @router.dispatch(*args) if args
    end
  end
end
