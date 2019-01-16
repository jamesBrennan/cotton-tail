# frozen_string_literal: true

module CottonTail
  # Route pattern matcher
  class Route < SimpleDelegator
    def initialize(pattern)
      @pattern = pattern
      super build_regex
    end

    def extract_params(routing_key)
      return {} unless match? routing_key

      match(routing_key).named_captures
    end

    def binding
      segments.map(&:binding).join('.')
    end

    private

    def explode
      @pattern.split('.').map(&RouteSegment.method(:new))
    end

    def collapse
      segments.zip(separators).join
    end

    def segments
      @segments ||= explode
    end

    def separators
      separators = segments.each_with_index.map do |segment, idx|
        [Regexp.escape('.')].tap do |sep|
          sep << '?' if segment.hash? && idx.zero?
        end
      end
      separators.map(&:join)[0..-2]
    end

    def build_regex
      Regexp.new "^#{collapse}$"
    end
  end
end
