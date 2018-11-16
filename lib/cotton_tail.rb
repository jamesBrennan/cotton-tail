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
    def configure
      return configuration unless block_given?

      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
