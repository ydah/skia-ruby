# frozen_string_literal: true

module Skia
  class PathEffect < Base
    def initialize(ptr, owner: nil)
      super(ptr, owner ? nil : :sk_path_effect_unref, owner: owner)
    end

    def self.wrap(ptr, owner: nil)
      return nil if ptr.nil? || ptr.null?

      new(ptr, owner: owner)
    end

    def self.dash(intervals, phase: 0.0)
      unless intervals.is_a?(Array) && intervals.length >= 2
        raise ArgumentError, 'intervals must be an array with at least 2 elements'
      end

      interval_values = intervals.map(&:to_f)
      intervals_ptr = FFI::MemoryPointer.new(:float, interval_values.length)
      intervals_ptr.write_array_of_float(interval_values)

      ptr = Native.sk_path_effect_create_dash(intervals_ptr, interval_values.length, phase.to_f)
      raise Error, 'Failed to create dash path effect' if ptr.nil? || ptr.null?

      new(ptr)
    end
  end
end
