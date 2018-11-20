# frozen_string_literal: true

require 'middleware'
require 'logger'

module CottonTail
  # Top level namespace for Middleware
  module Middleware
    autoload :Router, 'cotton_tail/middleware/router'

    DEFAULT_STACK = ::Middleware::Builder.new do |b|
      b.use Router
    end
  end
end
