# frozen_string_literal: true

module CottonTail
  # RouteSegment represents an individual segment of a CottonTail route
  class RouteSegment
    def initialize(value)
      @value = value
    end

    def to_regex
      Regexp.new regex_def
    end

    private

    def regex_def
      replacers.inject(@value) { |val, replacer| replacer.call(val) }
    end

    def replace_named_captures(pattern)
      pattern.gsub(/[*#]:(\w+)/, '(?<\1>[^.]+)')
    end

    def replace_single_wildcard(pattern)
      pattern.gsub('*', '([^.]+)')
    end

    def replace_multi_wildcard(pattern)
      pattern.gsub(/\.?#\.?/, '([^.]{0,}\.?)+')
    end

    def replacers
      [
        method(:replace_named_captures),
        method(:replace_single_wildcard),
        method(:replace_multi_wildcard)
      ]
    end
  end
end
