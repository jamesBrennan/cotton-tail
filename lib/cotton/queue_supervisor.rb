# frozen_string_literal: true

require 'fiber'

module Cotton
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

    # Start the supervisor, process all pending messages, and shut down
    def run
      @queue.close
      start
    end

    private

    def reader
      @reader ||= Fiber.new do
        return false if @queue.empty? && @queue.closed?
        @queue.pop
      end
    end

    def process
      while @status == :started && reader.alive?
        router_args = reader.resume
        @router.dispatch(*router_args) if router_args
      end
    end
  end
end
