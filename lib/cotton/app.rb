# frozen_string_literal: true

module Cotton
  # App is the main class for a Cotton server
  class App
    def initialize(queue_strategy: Queue::Memory, routing_strategy: Router)
      @dependencies = {
        queue_strategy: queue_strategy,
        routing_strategy: routing_strategy
      }
    end

    # Define message routing
    def define(&block)
      @definition = DSL::App.new(**@dependencies)
      @definition.instance_eval(&block)
      self
    end

    def queues
      @definition.queues
    end

    # Get a single message queue
    def queue(name)
      queues[name]
    end

    # Start the app, process all pending messages, and then shutdown
    def run
      supervisors.map(&:run).each(&:join)
    end

    private

    def supervisors
      @supervisors ||= queues.map do |_name, queue|
        Queue::Supervisor.new(queue, on_message: @definition.router)
      end
    end
  end
end
