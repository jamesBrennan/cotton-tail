# frozen_string_literal: true

require 'bunny'

# Top level namespace for CottonTail
module CottonTail
  autoload :App, 'cotton_tail/app'
  autoload :Configuration, 'cotton_tail/configuration'
  autoload :DSL, 'cotton_tail/dsl'
  autoload :Queue, 'cotton_tail/queue'
  autoload :Router, 'cotton_tail/router'
  autoload :Version, 'cotton_tail/version'

  class << self
    # Yields or returns the CottonTail::Configuration instance if given a block.
    def configure
      return configuration unless block_given?

      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def application(**kwargs)
      raise AppInstantiationError, kwargs if @application && !kwargs.empty?

      @application ||= App.new(**kwargs)
    end

    def reset
      @configuration = nil
      @application = nil
    end
  end

  # Raised when .application is called with arguments and an @application instance
  # is already defined
  class AppInstantiationError < StandardError
    def initialize(args)
      super message(args)
    end

    private

    def message(args)
      <<-MSG
          CottonTail.application called with args #{args}, which will be ignored since
          an instance of CottonTail::App has already been instantiated and memoized.
      MSG
    end
  end
end
