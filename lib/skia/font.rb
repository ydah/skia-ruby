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

    def count_glyphs(text, encoding: :utf8)
      text_bytes = encode_text(text, encoding)
      Native.sk_font_text_to_glyphs(@ptr, text_bytes, text_bytes.bytesize, encoding, nil, 0)
    end

    def text_to_glyphs(text, encoding: :utf8)
      text_bytes = encode_text(text, encoding)
      count = Native.sk_font_text_to_glyphs(@ptr, text_bytes, text_bytes.bytesize, encoding, nil, 0)
      return [] if count <= 0

      glyphs_ptr = FFI::MemoryPointer.new(:uint16, count)
      Native.sk_font_text_to_glyphs(@ptr, text_bytes, text_bytes.bytesize, encoding, glyphs_ptr, count)
      glyphs_ptr.read_array_of_uint16(count)
    end

    def glyph_x_positions(glyphs, origin: 0.0)
      return [] if glyphs.empty?

      glyphs_ptr = FFI::MemoryPointer.new(:uint16, glyphs.length)
      glyphs_ptr.write_array_of_uint16(glyphs)

      xpos_ptr = FFI::MemoryPointer.new(:float, glyphs.length)
      Native.sk_font_get_xpos(@ptr, glyphs_ptr, glyphs.length, xpos_ptr, origin.to_f)
      xpos_ptr.read_array_of_float(glyphs.length)
    end

    private

    def encode_text(text, encoding)
      str = text.to_s
      case encoding
      when :utf8
        str.encode('UTF-8')
      when :utf16
        str.encode('UTF-16LE')
      when :utf32
        str.encode('UTF-32LE')
      when :glyph_id
        str.dup.force_encoding(Encoding::ASCII_8BIT)
      else
        raise ArgumentError, "Unsupported text encoding: #{encoding.inspect}"
      end
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
