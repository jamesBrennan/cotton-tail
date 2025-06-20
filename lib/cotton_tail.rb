# frozen_string_literal: true

require 'bunny'

# Top level namespace for CottonTail
module CottonTail
  autoload :App, 'cotton_tail/app'
  autoload :Configuration, 'cotton_tail/configuration'
  autoload :DSL, 'cotton_tail/dsl'
  autoload :MessageProperties, 'cotton_tail/message_properties'
  autoload :Middleware, 'cotton_tail/middleware'
  autoload :Queue, 'cotton_tail/queue'
  autoload :Request, 'cotton_tail/request'
  autoload :Route, 'cotton_tail/route'
  autoload :RouteSegment, 'cotton_tail/route_segment'
  autoload :Version, 'cotton_tail/version'

  Response = Struct.new(:body)

  class RouteConflictError < StandardError
  end

  class UndefinedRouteError < StandardError
  end
end
