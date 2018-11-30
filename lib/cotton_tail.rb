# frozen_string_literal: true

require 'bunny'

# Top level namespace for CottonTail
module CottonTail
  autoload :App, 'cotton_tail/app'
  autoload :Configuration, 'cotton_tail/configuration'
  autoload :DSL, 'cotton_tail/dsl'
  autoload :Middleware, 'cotton_tail/middleware'
  autoload :Queue, 'cotton_tail/queue'
  autoload :Router, 'cotton_tail/router'
  autoload :Version, 'cotton_tail/version'

  Request = Struct.new(:delivery_info, :properties, :payload) do
    def routing_key
      delivery_info[:routing_key]
    end

    def delivery_tag
      delivery_info[:delivery_tag]
    end

    def channel
      delivery_info[:channel]
    end
  end

  Response = Struct.new(:body)

  class UndefinedRouteError < StandardError
  end
end
