# frozen_string_literal: true

require 'middleware'
require 'logger'

module CottonTail
  # Top level namespace for Middleware
  module Middleware
    autoload :Router, 'cotton_tail/middleware/router'

    def self.default_stack(app)
      ::Middleware::Builder.new do |b|
        b.use Router, handlers: app.routes.handlers
      end
    end
  end
end
