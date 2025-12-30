# frozen_string_literal: true

module Skia
  class Font < Base
    def initialize(typeface = nil, size = 12.0, scale_x = 1.0, skew_x = 0.0)
      ptr = if typeface
              Native.sk_font_new_with_values(typeface.ptr, size.to_f, scale_x.to_f, skew_x.to_f)
            else
              Native.sk_font_new
            end
      raise Error, 'Failed to create font' if ptr.nil? || ptr.null?

      super(ptr, :sk_font_delete)

      # Set size explicitly when no typeface is provided (sk_font_new uses default size)
      self.size = size unless typeface
    end

    def typeface
      ptr = Native.sk_font_get_typeface(@ptr)
      return nil if ptr.nil? || ptr.null?

      Typeface.new(ptr)
    end

    def typeface=(value)
      Native.sk_font_set_typeface(@ptr, value&.ptr)
    end

    def size
      Native.sk_font_get_size(@ptr)
    end

    def size=(value)
      Native.sk_font_set_size(@ptr, value.to_f)
    end

    def metrics
      metrics_struct = Native::SKFontMetrics.new
      Native.sk_font_get_metrics(@ptr, metrics_struct)
      FontMetrics.new(metrics_struct)
    end

    def measure_text(text, paint = nil)
      text_bytes = text.encode('UTF-8')
      bounds = Native::SKRect.new
      width = Native.sk_font_measure_text(@ptr, text_bytes, text_bytes.bytesize, :utf8, bounds, paint&.ptr)
      [width, Rect.from_struct(bounds)]
    end
  end

  class FontMetrics
    attr_reader :top, :ascent, :descent, :bottom, :leading, :avg_char_width, :max_char_width, :x_min, :x_max,
                :x_height, :cap_height, :underline_thickness, :underline_position, :strikeout_thickness, :strikeout_position

    def initialize(struct)
      @top = struct[:top]
      @ascent = struct[:ascent]
      @descent = struct[:descent]
      @bottom = struct[:bottom]
      @leading = struct[:leading]
      @avg_char_width = struct[:avgCharWidth]
      @max_char_width = struct[:maxCharWidth]
      @x_min = struct[:xMin]
      @x_max = struct[:xMax]
      @x_height = struct[:xHeight]
      @cap_height = struct[:capHeight]
      @underline_thickness = struct[:underlineThickness]
      @underline_position = struct[:underlinePosition]
      @strikeout_thickness = struct[:strikeoutThickness]
      @strikeout_position = struct[:strikeoutPosition]
    end
  end
end
