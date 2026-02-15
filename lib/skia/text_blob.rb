# frozen_string_literal: true

module Skia
  class TextBlob < Base
    def initialize(ptr)
      super(ptr, :sk_textblob_unref)
    end

    def self.from_text(text, font, x: 0.0, y: 0.0, bounds: nil, encoding: :utf8)
      glyphs = font.text_to_glyphs(text, encoding: encoding)
      return nil if glyphs.empty?

      builder = Native.sk_textblob_builder_new
      raise Error, 'Failed to create text blob builder' if builder.nil? || builder.null?

      begin
        run_buffer = Native::SKRunBuffer.new
        bounds_struct = bounds&.to_struct
        Native.sk_textblob_builder_alloc_run_pos_h(builder, font.ptr, glyphs.length, y.to_f, bounds_struct, run_buffer)

        glyphs_ptr = run_buffer[:glyphs]
        glyphs_ptr.write_array_of_uint16(glyphs)

        xpos = font.glyph_x_positions(glyphs, origin: x.to_f)
        xpos_ptr = run_buffer[:pos]
        xpos_ptr.write_array_of_float(xpos)

        ptr = Native.sk_textblob_builder_make(builder)
        return nil if ptr.nil? || ptr.null?

        new(ptr)
      ensure
        Native.sk_textblob_builder_delete(builder) if builder && !builder.null?
      end
    end

    def bounds
      rect_struct = Native::SKRect.new
      Native.sk_textblob_get_bounds(@ptr, rect_struct)
      Rect.from_struct(rect_struct)
    end

    def unique_id
      Native.sk_textblob_get_unique_id(@ptr)
    end
  end
end
