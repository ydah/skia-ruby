# frozen_string_literal: true

module Skia
  class ImageInfo
    attr_reader :width, :height, :color_type, :alpha_type, :color_space

    def initialize(width:, height:, color_type: :rgba_8888, alpha_type: :premul, color_space: nil)
      @width = width.to_i
      @height = height.to_i
      @color_type = color_type
      @alpha_type = alpha_type
      @color_space = color_space

      raise ArgumentError, 'width must be positive' if @width <= 0
      raise ArgumentError, 'height must be positive' if @height <= 0
      raise ArgumentError, 'color_space must be a Skia::ColorSpace or nil' unless @color_space.nil? || @color_space.is_a?(ColorSpace)
    end

    def self.from_struct(struct, retain_color_space: true)
      color_space = ColorSpace.wrap(struct[:colorspace], retain: retain_color_space)
      new(
        width: struct[:width],
        height: struct[:height],
        color_type: struct[:colorType],
        alpha_type: struct[:alphaType],
        color_space: color_space
      )
    end

    def to_struct
      struct = Native::SKImageInfo.new
      struct[:width] = @width
      struct[:height] = @height
      struct[:colorType] = @color_type
      struct[:alphaType] = @alpha_type
      struct[:colorspace] = @color_space&.ptr
      struct
    end

    def bytes_per_pixel
      case @color_type
      when :alpha_8, :gray_8
        1
      when :rgb_565, :argb_4444
        2
      when :rgba_f16
        8
      when :rgba_f32
        16
      else
        4
      end
    end

    def min_row_bytes
      @width * bytes_per_pixel
    end
  end
end
