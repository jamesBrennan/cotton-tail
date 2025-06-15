# frozen_string_literal: true

require 'delegate'

module CottonTail
  # RouteSegment implements the pattern matching for route segments
  class RouteSegment < SimpleDelegator
    ##
    # Initializes a RouteSegment with a string pattern, transforming it into a regular expression for route matching.
    #
    # @param value [String] The route segment pattern, which may include wildcards or named wildcards.
    def initialize(value)
      @value = value
      @transformed = definition(value)
      super(Regexp.new "^#{@transformed}$")
    end

    ##
    # Checks if the route segment is a single wildcard or a named single wildcard.
    #
    # @return [Boolean] true if the segment is '*' or in the form '*:name', false otherwise
    def star?
      /^#{STAR}|#{NAMED_STAR}$/.match? @value
    end

    def hash?
      /^#{HASH}|#{NAMED_HASH}$/.match? @value
    end

    ##
    # Returns the binding identifier for the route segment.
    #
    # Returns "*" for single wildcards, "#" for multi wildcards, or the original segment string otherwise.
    # @return [String] The binding identifier for this segment.
    def binding
      return '*' if star?

      return '#' if hash?

      @value
    end

    ##
    # Determines if the given value matches the route segment pattern.
    #
    # Returns false if the value is nil or an empty string. Only string values are considered for matching.
    #
    # @param other [Object] The value to test against the route segment pattern.
    # @return [Boolean] True if the value matches the pattern, false otherwise.
    def match?(other)
      return false unless other
      return false if other.to_s.empty?
      return super if other.is_a?(String)

      false
    end

    ##
    # Returns the string representation of the route segment's transformed pattern.
    #
    # @return [String] The transformed pattern as a string
    def to_s
      @transformed.to_s
    end

    private

    TRANSFORM = ->(val, func) { func.call(val) }

    def definition(value)
      transformers.reduce(value, &TRANSFORM)
    end

    # Converts named route segment to Regexp named capture group
    #   "#:foo" -> "(?<foo>.+)"
    def sub_named_group_wildcard(pattern)
      pattern.gsub(NAMED_HASH, '(?<\1>.+)')
    end

    # Converts named route segment to Regexp named capture group
    #   "*:foo" -> "(?<foo>[^.]+)"
    def sub_named_single_wildcard(pattern)
      pattern.gsub(NAMED_STAR, '(?<\1>[^.]+)')
    end

    def sub_single_wildcard(pattern)
      pattern.gsub(STAR, '([^.]+)')
    end

    def sub_multi_wildcard(pattern)
      pattern.gsub(HASH, '([^.]{0,}\.?)+')
    end

    ##
    # Returns an array of methods used to transform route segment patterns into regular expression components.
    #
    # @return [Array<Method>] List of transformation methods applied in order
    def transformers
      [
        method(:sub_named_group_wildcard),
        method(:sub_named_single_wildcard),
        method(:sub_single_wildcard),
        method(:sub_multi_wildcard)
      ]
    end

    STAR = /\*/
    HASH = /#/
    NAMED = /:(\w+)/
    NAMED_STAR = /#{STAR}#{NAMED}/
    NAMED_HASH = /#{HASH}#{NAMED}/

    private_constant :TRANSFORM, :STAR, :HASH, :NAMED, :NAMED_STAR, :NAMED_HASH
  end
end
