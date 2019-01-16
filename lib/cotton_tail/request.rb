# frozen_string_literal: true

module CottonTail
  # Value object wrapper for Bunny Message
  class Request
    extend Forwardable

    attr_reader :delivery_info, :properties, :payload

    def initialize(delivery_info, properties, payload)
      @delivery_info = delivery_info
      @properties = properties
      @payload = payload
    end

    def to_a
      [delivery_info, properties, payload]
    end

    def to_h
      {
        delivery_info: delivery_info,
        properties: properties,
        payload: payload
      }
    end

    def ==(other)
      to_h == other.to_h
    end

    def_delegators :delivery_info, :routing_key, :delivery_tag, :channel
    def_delegators :properties, :route_params
  end
end
