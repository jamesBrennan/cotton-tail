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

    def collapse(segments)
      segments.zip(separators(segments)).join
    end

    def separators(segments)
      separators = segments.each_with_index.map do |segment, idx|
        [Regexp.escape('.')].tap do |sep|
          sep << '?' if segment.hash? && idx.zero?
        end
      end
      separators.map(&:join)[0..-2]
    end

    def definition(pattern)
      collapse segments(pattern)
    end

    def segments(pattern)
      explode(pattern).map(&RouteSegment.method(:new))
    end

    def build_regex(pattern)
      Regexp.new "^#{definition(pattern)}$"
    end
  end
end
