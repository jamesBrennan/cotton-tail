# frozen_string_literal: true

require 'cotton/version'

# Top level namespace for Cotton
module Cotton
  autoload :App, 'cotton/app'
  autoload :DSL, 'cotton/dsl'
  autoload :Queue, 'cotton/queue'
  autoload :QueueSupervisor, 'cotton/queue_supervisor'
  autoload :Router, 'cotton/router'
  autoload :Topic, 'cotton/topic'
end
