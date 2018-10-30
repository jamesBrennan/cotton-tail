# frozen_string_literal: true

module Cotton
  # App is the main class for a Cotton server
  class App
    def initialize(queue_strategy: Queue, routing_strategy: Router)
      @dependencies = {
        queue_strategy: queue_strategy,
        routing_strategy: routing_strategy
      }
    end

    # Define message routing
    def define(&block)
      @dsl = DSL.new(**@dependencies)
      @dsl.instance_eval(&block)
      self
    end

    def queues
      @dsl.queues
    end

    # Get a single message queue
    def queue(name)
      queues[name]
    end

    # Start the app, process all pending messages, and then shutdown
    def run
      supervisors.map do |supervisor|
        Thread.new { supervisor.run }
      end.each(&:join)
    end

    private

    def supervisors
      queues.map { |_name, queue| QueueSupervisor.new(queue, router: @dsl.router) }
    end
  end
end
