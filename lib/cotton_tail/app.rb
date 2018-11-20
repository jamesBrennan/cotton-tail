# frozen_string_literal: true

module CottonTail
  # App is the main class for a CottonTail server
  class App
    attr_reader :env, :config

    def initialize(queue_strategy: Queue::Bunny, env: {}, connection: Bunny.new, config: Configuration.new)
      @dependencies = { queue_strategy: queue_strategy, connection: connection }
      @env = env
      @config = config
      @connection = connection.start
    end

    def queues
      routes.queues
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

      sleep 0.01 while running?
    end

    def routes
      @routes ||= DSL::Routes.new(**@dependencies)
    end

    private

    def supervisors
      @supervisors ||= queues.map do |_name, queue|
        Queue::Supervisor.new(queue, app: self)
      end
    end

    def running?
      supervisors.any?(&:running?)
    end
  end
end
