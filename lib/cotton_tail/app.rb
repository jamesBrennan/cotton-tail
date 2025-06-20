# frozen_string_literal: true

module CottonTail
  # App is the main class for a CottonTail server
  class App
    attr_reader :env

    def initialize(queue_strategy: Queue::Bunny, env: {}, connection: Bunny.new)
      @dependencies = { queue_strategy: queue_strategy, connection: connection }
      @env = env
      @connection = connection.start
    end

    def config
      @config ||= Configuration.new(middleware: Middleware.default_stack(self))
    end

    def queues
      routes.queues
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

    def stop
      supervisors.map(&:stop)
      @connection.close
    end

    def routes
      @routes ||= DSL::Routes.new(**@dependencies)
    end

    private

    def supervisors
      @supervisors ||= queues.map do |queue|
        Queue::Supervisor.new(queue, app: self)
      end
    end

    def running?
      supervisors.any?(&:running?)
    end
  end
end
