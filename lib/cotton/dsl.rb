# frozen_string_literal: true

module Cotton
  # DSL namespace
  module DSL
    autoload :App, 'cotton/dsl/app'
    autoload :Queue, 'cotton/dsl/queue'
    autoload :Topic, 'cotton/dsl/topic'
  end
end
