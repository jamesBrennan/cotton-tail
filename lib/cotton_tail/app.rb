# frozen_string_literal: true

module CottonTail
  # App is the main class for a CottonTail server
  class App
    def initialize(queue_strategy: Queue::Bunny, routing_strategy: Router)
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

    def start
      supervisors.map(&:start)
      puts 'Waiting for messages ...'

      sleep 0.1 while running?
    end

    private

    def supervisors
      @supervisors ||= queues.map do |_name, queue|
        Queue::Supervisor.new(queue, on_message: @definition.router)
      end
    end

    def running?
      supervisors.any?(&:running?)
    end
  end
end
