# frozen_string_literal: true

module CottonTail
  # Route pattern matcher
  class Route < SimpleDelegator
    def initialize(pattern)
      super build_regex(pattern)
    end

    def extract_params(routing_key)
      return {} unless match? routing_key

      match(routing_key).named_captures
    end

    private

    def explode(pattern)
      pattern.split('.')
    end

    def definition(pattern)
      segments(pattern).join Regexp.escape('.')
    end

    def segments(pattern)
      explode(pattern).map(&RouteSegment.method(:new))
    end

    def build_regex(pattern)
      Regexp.new "^#{definition(pattern)}$"
    end
  end
end
