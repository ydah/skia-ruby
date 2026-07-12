# frozen_string_literal: true

module Skia
  class ColorFilter < Base
    COLOR_MATRIX_SIZE = 20
    TABLE_SIZE = 256

    def initialize(ptr, owner: nil)
      super(ptr, owner ? nil : :sk_colorfilter_unref, owner: owner)
    end

    def self.wrap(ptr, owner: nil)
      return nil if ptr.nil? || ptr.null?

      new(ptr, owner: owner)
    end

    def self.mode(color, blend_mode = :src_over)
      color_value = color.is_a?(Color) ? color.to_i : color
      ptr = Native.sk_colorfilter_new_mode(color_value, blend_mode)
      raise Error, 'Failed to create color filter' if ptr.nil? || ptr.null?

      new(ptr)
    end

    def self.lighting(multiply, add)
      ptr = Native.sk_colorfilter_new_lighting(color_value(multiply), color_value(add))
      build(ptr, 'lighting')
    end

    def self.compose(outer, inner)
      validate_filter!(outer)
      validate_filter!(inner)
      build(Native.sk_colorfilter_new_compose(outer.ptr, inner.ptr), 'composed')
    end

    def self.lerp(weight, from, to)
      validate_filter!(from)
      validate_filter!(to)
      build(Native.sk_colorfilter_new_lerp(weight.to_f, from.ptr, to.ptr), 'interpolated')
    end

    def self.matrix(values)
      build(Native.sk_colorfilter_new_color_matrix(float_matrix(values)), 'color matrix')
    end

    def self.hsla_matrix(values)
      build(Native.sk_colorfilter_new_hsla_matrix(float_matrix(values)), 'HSLA matrix')
    end

    def self.srgb_to_linear_gamma
      borrowed(Native.sk_colorfilter_new_srgb_to_linear_gamma, 'sRGB-to-linear gamma')
    end

    def self.linear_to_srgb_gamma
      borrowed(Native.sk_colorfilter_new_linear_to_srgb_gamma, 'linear-to-sRGB gamma')
    end

    def self.luma
      build(Native.sk_colorfilter_new_luma_color, 'luma')
    end

    def self.table(values)
      build(Native.sk_colorfilter_new_table(byte_table(values)), 'table')
    end

    def self.argb_table(alpha:, red:, green:, blue:)
      ptr = Native.sk_colorfilter_new_table_argb(
        byte_table(alpha), byte_table(red), byte_table(green), byte_table(blue)
      )
      build(ptr, 'ARGB table')
    end

    def self.color_value(value)
      value.is_a?(Color) ? value.to_i : value
    end
    private_class_method :color_value

    def self.validate_filter!(value)
      raise ArgumentError, 'expected a Skia::ColorFilter' unless value.is_a?(ColorFilter)
    end
    private_class_method :validate_filter!

    def self.float_matrix(values)
      raise ArgumentError, "matrix must contain exactly #{COLOR_MATRIX_SIZE} values" unless values.length == COLOR_MATRIX_SIZE

      pointer = FFI::MemoryPointer.new(:float, COLOR_MATRIX_SIZE)
      pointer.write_array_of_float(values.map(&:to_f))
      pointer
    end
    private_class_method :float_matrix

    def self.byte_table(values)
      unless values.length == TABLE_SIZE && values.all? { |value| value.is_a?(Integer) && value.between?(0, 255) }
        raise ArgumentError, "table must contain exactly #{TABLE_SIZE} byte values"
      end

      pointer = FFI::MemoryPointer.new(:uint8, TABLE_SIZE)
      pointer.write_array_of_uint8(values)
      pointer
    end
    private_class_method :byte_table

    def self.build(ptr, description)
      raise Error, "Failed to create #{description} color filter" if ptr.nil? || ptr.null?

      new(ptr)
    end
    private_class_method :build

    def self.borrowed(ptr, description)
      raise Error, "Failed to create #{description} color filter" if ptr.nil? || ptr.null?

      new(ptr, owner: Native)
    end
    private_class_method :borrowed
  end
end
