# frozen_string_literal: true

module Skia
  class Pixmap < Base
    def initialize(ptr = nil, owner: nil)
      super(ptr || Native.sk_pixmap_new, :sk_pixmap_destructor, owner: owner)
      @pixel_storage = nil
    end

    def self.from_pixels(image_info, pixels, row_bytes: nil)
      info = coerce_image_info(image_info)
      bytes = pixels.is_a?(String) ? pixels.dup : pixels.pack('C*')
      row_bytes ||= info.min_row_bytes

      raise ArgumentError, "pixel buffer is too small: #{bytes.bytesize} bytes" if bytes.bytesize < row_bytes * info.height

      storage = FFI::MemoryPointer.new(:uint8, bytes.bytesize)
      storage.write_bytes(bytes)

      ptr = Native.sk_pixmap_new_with_params(info.to_struct, storage, row_bytes)
      raise Error, 'Failed to create pixmap from pixels' if ptr.nil? || ptr.null?

      pixmap = new(ptr)
      pixmap.instance_variable_set(:@pixel_storage, storage)
      pixmap
    end

    def self.from_numo(array, alpha_type: :unpremul, color_space: nil)
      ensure_numo!
      pixels = Numo::UInt8.cast(array)
      shape = pixels.shape
      raise ArgumentError, "Numo array shape must be [height, width, 4], got #{shape.inspect}" unless shape.length == 3 && shape[2] == 4

      info = ImageInfo.new(width: shape[1], height: shape[0], color_type: :rgba_8888, alpha_type: alpha_type,
                           color_space: color_space)
      from_pixels(info, pixels.to_binary, row_bytes: info.min_row_bytes)
    end

    def info
      info_struct = Native::SKImageInfo.new
      Native.sk_pixmap_get_info(@ptr, info_struct)
      ImageInfo.from_struct(info_struct)
    end

    def row_bytes
      Native.sk_pixmap_get_row_bytes(@ptr)
    end

    def color_space
      ColorSpace.wrap(Native.sk_pixmap_get_colorspace(@ptr), retain: true)
    end

    def color_space=(value)
      raise ArgumentError, 'color_space must be a Skia::ColorSpace or nil' unless value.nil? || value.is_a?(ColorSpace)

      Native.sk_pixmap_set_colorspace(@ptr, value&.ptr)
    end

    def pixel_color(x, y)
      Color.new(Native.sk_pixmap_get_pixel_color(@ptr, x.to_i, y.to_i))
    end

    def opaque?
      Native.sk_pixmap_compute_is_opaque(@ptr)
    end

    def writable_addr(x = nil, y = nil)
      if x.nil? || y.nil?
        Native.sk_pixmap_get_writable_addr(@ptr)
      else
        Native.sk_pixmap_get_writeable_addr_with_xy(@ptr, x.to_i, y.to_i)
      end
    end

    def read_pixels(dst_info, src_x: 0, src_y: 0, row_bytes: nil)
      info = self.class.coerce_image_info(dst_info)
      row_bytes ||= info.min_row_bytes
      byte_size = row_bytes * info.height
      pixels = FFI::MemoryPointer.new(:uint8, byte_size)

      ok = Native.sk_pixmap_read_pixels(@ptr, info.to_struct, pixels, row_bytes, src_x.to_i, src_y.to_i)
      raise Error, 'Failed to read pixels from pixmap' unless ok

      pixels.read_bytes(byte_size)
    end

    def to_numo
      self.class.ensure_numo!
      source = info
      rgba_info = ImageInfo.new(width: source.width, height: source.height, color_type: :rgba_8888, alpha_type: :unpremul,
                                color_space: source.color_space)
      bytes = read_pixels(rgba_info)
      Numo::UInt8.from_binary(bytes).reshape(source.height, source.width, 4)
    end

    def extract_subset(rect)
      irect = coerce_irect(rect)
      subset = self.class.new
      success = Native.sk_pixmap_extract_subset(@ptr, subset.ptr, irect.to_struct)
      return nil unless success

      subset.send(:keep_alive, self)
      subset
    end

    def reset
      Native.sk_pixmap_reset(@ptr)
      @pixel_storage = nil
      @owner = nil
      self
    end

    private

    def self.coerce_image_info(image_info)
      return image_info if image_info.is_a?(ImageInfo)

      raise ArgumentError, 'image_info must be a Skia::ImageInfo'
    end

    def self.ensure_numo!
      require 'numo/narray'
    rescue LoadError
      raise UnsupportedOperationError, 'Numo conversion requires the numo-narray gem'
    end

    def coerce_irect(rect)
      return rect if rect.is_a?(IRect)

      raise ArgumentError, 'rect must be a Skia::IRect'
    end

    def keep_alive(owner)
      @owner = owner
      self
    end
  end
end
