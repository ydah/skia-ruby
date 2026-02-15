# frozen_string_literal: true

module Skia
  class Bitmap < Base
    def initialize(ptr = nil)
      super(ptr || Native.sk_bitmap_new, nil)
      @pixel_storage = nil
    end

    def info
      info_struct = Native::SKImageInfo.new
      Native.sk_bitmap_get_info(@ptr, info_struct)
      ImageInfo.from_struct(info_struct)
    end

    def width
      info.width
    end

    def height
      info.height
    end

    def row_bytes
      Native.sk_bitmap_get_row_bytes(@ptr)
    end

    def byte_count
      Native.sk_bitmap_get_byte_count(@ptr)
    end

    def pixels_ptr
      Native.sk_bitmap_get_pixels(@ptr, nil)
    end

    def pixels
      ptr = pixels_ptr
      return nil if ptr.nil? || ptr.null?

      ptr.read_bytes(byte_count)
    end

    def allocated?
      !Native.sk_bitmap_is_null(@ptr)
    end

    def immutable?
      Native.sk_bitmap_is_immutable(@ptr)
    end

    def immutable=(value)
      return unless value

      Native.sk_bitmap_set_immutable(@ptr)
    end

    def alloc_pixels(image_info, flags: nil)
      info = coerce_image_info(image_info)
      row_bytes = info.min_row_bytes
      @pixel_storage = nil
      return Native.sk_bitmap_try_alloc_pixels_with_flags(@ptr, info.to_struct, flags.to_i) if flags

      Native.sk_bitmap_try_alloc_pixels(@ptr, info.to_struct, row_bytes)
    end

    def erase(color, rect: nil)
      color_value = color.is_a?(Color) ? color.to_i : color
      if rect
        irect = coerce_irect(rect)
        Native.sk_bitmap_erase_rect(@ptr, color_value, irect.to_struct)
      else
        Native.sk_bitmap_erase(@ptr, color_value)
      end
      self
    end

    def pixel_color(x, y)
      Color.new(Native.sk_bitmap_get_pixel_color(@ptr, x.to_i, y.to_i))
    end

    def peek_pixels
      pixmap = Pixmap.new
      return nil unless Native.sk_bitmap_peek_pixels(@ptr, pixmap.ptr)

      pixmap
    end

    def extract_subset(rect)
      irect = coerce_irect(rect)
      subset = self.class.new
      success = Native.sk_bitmap_extract_subset(subset.ptr, @ptr, irect.to_struct)
      return nil unless success

      subset
    end

    def make_shader(tile_x: :clamp, tile_y: :clamp, matrix: nil)
      matrix_struct = matrix&.to_struct
      sampling = Native::SKSamplingOptions.new
      sampling[:fMaxAniso] = 0
      sampling[:fUseCubic] = 0
      sampling[:fCubicB] = 0.0
      sampling[:fCubicC] = 0.0
      sampling[:fFilter] = :nearest
      sampling[:fMipmap] = :none

      ptr = Native.sk_bitmap_make_shader(@ptr, tile_x, tile_y, sampling, matrix_struct)
      raise Error, 'Failed to create shader from bitmap' if ptr.nil? || ptr.null?

      Shader.new(ptr)
    end

    def to_image
      ptr = Native.sk_image_new_from_bitmap(@ptr)
      raise Error, 'Failed to create image from bitmap' if ptr.nil? || ptr.null?

      Image.new(ptr)
    end

    def reset
      Native.sk_bitmap_reset(@ptr)
      @pixel_storage = nil
      self
    end

    private

    def coerce_image_info(image_info)
      return image_info if image_info.is_a?(ImageInfo)

      raise ArgumentError, 'image_info must be a Skia::ImageInfo'
    end

    def coerce_irect(rect)
      return rect if rect.is_a?(IRect)

      raise ArgumentError, 'rect must be a Skia::IRect'
    end
  end
end
