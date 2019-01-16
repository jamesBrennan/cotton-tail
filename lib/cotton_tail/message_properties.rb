# frozen_string_literal: true

module CottonTail
  # Wrapper around Bunny MessageProperties, used to supply route params
  class MessageProperties < Bunny::MessageProperties
    def merge(properties)
      self.class.new(@properties.merge(properties))
    end

    def route_params
      @properties[:route_params]
    end

    def ==(other)
      to_h == other.to_h
    end
  end
end
