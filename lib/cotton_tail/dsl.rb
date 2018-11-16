# frozen_string_literal: true

module CottonTail
  # DSL namespace
  module DSL
    autoload :Routes, 'cotton_tail/dsl/routes'
    autoload :Queue, 'cotton_tail/dsl/queue'
    autoload :Topic, 'cotton_tail/dsl/topic'
  end
end
