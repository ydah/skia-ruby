# frozen_string_literal: true

module Skia
  class Surface < Base
    attr_reader :width, :height

    def initialize(ptr, width, height)
      super(ptr, :sk_surface_unref)
      @width = width
      @height = height
      @pixel_storage = nil
    end

    def self.make_raster(width = nil, height = nil, image_info: nil, color_type: :rgba_8888, alpha_type: :premul,
                         color_space: nil, &)
      info = build_image_info(width, height, image_info, color_type: color_type, alpha_type: alpha_type, color_space: color_space)
      ptr = Native.sk_surface_new_raster(info.to_struct, 0, nil)
      raise Error, 'Failed to create raster surface' if ptr.nil? || ptr.null?

      yield_surface(new(ptr, info.width, info.height), &)
    end

    def self.make_raster_direct(width = nil, height = nil, pixels:, row_bytes:, image_info: nil, color_type: :rgba_8888,
                                alpha_type: :premul, color_space: nil, &)
      info = build_image_info(width, height, image_info, color_type: color_type, alpha_type: alpha_type, color_space: color_space)
      pixel_ptr, storage = coerce_pixels(pixels)
      ptr = Native.sk_surface_new_raster_direct(info.to_struct, pixel_ptr, row_bytes, nil, nil, nil)
      raise Error, 'Failed to create direct raster surface' if ptr.nil? || ptr.null?

      surface = new(ptr, info.width, info.height)
      surface.instance_variable_set(:@pixel_storage, storage)
      yield_surface(surface, &)
    end

    def self.make_null(width, height, &)
      ptr = Native.sk_surface_new_null(width.to_i, height.to_i)
      raise Error, 'Failed to create null surface' if ptr.nil? || ptr.null?

      yield_surface(new(ptr, width, height), &)
    end

    def self.make_render_target(context:, width: nil, height: nil, image_info: nil, budgeted: true, sample_count: 0,
                                origin: :top_left, create_mips: false, color_type: :rgba_8888, alpha_type: :premul,
                                color_space: nil, &)
      ensure_native_function!(:sk_surface_new_render_target, '.make_render_target')
      info = build_image_info(width, height, image_info, color_type: color_type, alpha_type: alpha_type, color_space: color_space)
      ptr = Native.sk_surface_new_render_target(
        coerce_pointer(context),
        budgeted,
        info.to_struct,
        sample_count.to_i,
        origin,
        nil,
        create_mips
      )
      raise Error, 'Failed to create render target surface' if ptr.nil? || ptr.null?

      yield_surface(new(ptr, info.width, info.height), &)
    end

    def self.make_backend_render_target(context:, backend_render_target:, width:, height:, origin: :top_left,
                                        color_type: :rgba_8888, color_space: nil, &)
      ensure_native_function!(:sk_surface_new_backend_render_target, '.make_backend_render_target')
      ptr = Native.sk_surface_new_backend_render_target(
        coerce_pointer(context),
        coerce_pointer(backend_render_target),
        origin,
        color_type,
        color_space&.ptr,
        nil
      )
      raise Error, 'Failed to create backend render target surface' if ptr.nil? || ptr.null?

      yield_surface(new(ptr, width, height), &)
    end

    def self.make_backend_texture(context:, backend_texture:, width:, height:, sample_count: 0, origin: :top_left,
                                  color_type: :rgba_8888, color_space: nil, &)
      ensure_native_function!(:sk_surface_new_backend_texture, '.make_backend_texture')
      ptr = Native.sk_surface_new_backend_texture(
        coerce_pointer(context),
        coerce_pointer(backend_texture),
        origin,
        sample_count.to_i,
        color_type,
        color_space&.ptr,
        nil
      )
      raise Error, 'Failed to create backend texture surface' if ptr.nil? || ptr.null?

      yield_surface(new(ptr, width, height), &)
    end

    def canvas
      @canvas = nil if @canvas&.closed?
      @canvas ||= Canvas.new(Native.sk_surface_get_canvas(ptr), owner: self)
    end

    def close
      @canvas&.close
      super
    end

    def snapshot(crop: nil)
      image_ptr = if crop
                    irect = crop.is_a?(IRect) ? crop : IRect.from_xywh(crop.left, crop.top, crop.width, crop.height)
                    Native.sk_surface_new_image_snapshot_with_crop(ptr, irect.to_struct)
                  else
                    Native.sk_surface_new_image_snapshot(ptr)
                  end
      raise Error, 'Failed to create image snapshot' if image_ptr.nil? || image_ptr.null?

      Image.new(image_ptr, owner: @pixel_storage)
    end

    def peek_pixels
      pixmap = Pixmap.new
      return nil unless Native.sk_surface_peek_pixels(ptr, pixmap.ptr)

      pixmap.send(:keep_alive, self)
      pixmap
    end

    def read_pixels(width: @width, height: @height, src_x: 0, src_y: 0, row_bytes: nil, image_info: nil, color_type: :rgba_8888,
                    alpha_type: :premul, color_space: nil)
      info = image_info || ImageInfo.new(width: width, height: height, color_type: color_type, alpha_type: alpha_type,
                                         color_space: color_space)
      row_bytes ||= info.min_row_bytes
      byte_size = row_bytes * info.height
      pixels = FFI::MemoryPointer.new(:uint8, byte_size)

      ok = Native.sk_surface_read_pixels(ptr, info.to_struct, pixels, row_bytes, src_x.to_i, src_y.to_i)
      raise Error, 'Failed to read pixels from surface' unless ok

      pixels.read_bytes(byte_size)
    end

    def draw
      yield canvas
      self
    end

    def encode(format = :png, quality = 100)
      pixmap = Native.sk_pixmap_new
      raise Error, 'Failed to create pixmap' if pixmap.nil? || pixmap.null?

      begin
        raise Error, 'Failed to peek pixels from surface' unless Native.sk_surface_peek_pixels(ptr, pixmap)

        stream = Native.sk_dynamicmemorywstream_new
        raise Error, 'Failed to create stream' if stream.nil? || stream.null?

        begin
          success = case format
                    when :png
                      options = Native::SKPngEncoderOptions.new
                      options[:fFilterFlags] = :all
                      options[:fZLibLevel] = 6
                      options[:fComments] = nil
                      options[:fICCProfile] = nil
                      options[:fICCProfileDescription] = nil
                      Native.sk_pngencoder_encode(stream, pixmap, options)
                    when :jpeg, :jpg
                      options = Native::SKJpegEncoderOptions.new
                      options[:fQuality] = quality
                      options[:fDownsample] = :downsample_420
                      options[:fAlphaOption] = :ignore
                      options[:xmpMetadata] = nil
                      options[:fICCProfile] = nil
                      options[:fICCProfileDescription] = nil
                      Native.sk_jpegencoder_encode(stream, pixmap, options)
                    when :webp
                      options = Native::SKWebpEncoderOptions.new
                      options[:fCompression] = :lossy
                      options[:fQuality] = quality.to_f
                      options[:fICCProfile] = nil
                      options[:fICCProfileDescription] = nil
                      Native.sk_webpencoder_encode(stream, pixmap, options)
                    else
                      options = Native::SKPngEncoderOptions.new
                      options[:fFilterFlags] = :all
                      options[:fZLibLevel] = 6
                      options[:fComments] = nil
                      options[:fICCProfile] = nil
                      options[:fICCProfileDescription] = nil
                      Native.sk_pngencoder_encode(stream, pixmap, options)
                    end

          raise Error, "Failed to encode surface as #{format}" unless success

          data_ptr = Native.sk_dynamicmemorywstream_detach_as_data(stream)
          raise Error, 'Failed to get encoded data' if data_ptr.nil? || data_ptr.null?

          Data.new(data_ptr)
        ensure
          Native.sk_dynamicmemorywstream_destroy(stream)
        end
      ensure
        Native.sk_pixmap_destructor(pixmap)
      end
    end

    def save(path, format: nil, quality: 100)
      format ||= detect_format_from_path(path)
      data = encode(format, quality)
      File.binwrite(path, data.to_s)
      self
    end

    def save_png(path, quality = 100)
      save(path, format: :png, quality: quality)
    end

    def save_jpeg(path, quality = 80)
      save(path, format: :jpeg, quality: quality)
    end

    def save_webp(path, quality = 80)
      save(path, format: :webp, quality: quality)
    end

    private

    def self.build_image_info(width, height, image_info, color_type:, alpha_type:, color_space:)
      return image_info if image_info.is_a?(ImageInfo)
      raise ArgumentError, 'width and height are required when image_info is not provided' if width.nil? || height.nil?

      ImageInfo.new(
        width: width,
        height: height,
        color_type: color_type,
        alpha_type: alpha_type,
        color_space: color_space
      )
    end

    def self.coerce_pixels(pixels)
      if pixels.is_a?(FFI::Pointer)
        [pixels, pixels]
      elsif pixels.is_a?(String)
        storage = FFI::MemoryPointer.new(:uint8, pixels.bytesize)
        storage.write_bytes(pixels)
        [storage, storage]
      else
        raise ArgumentError, 'pixels must be FFI::Pointer or String'
      end
    end

    def self.coerce_pointer(value)
      return value if value.is_a?(FFI::Pointer)
      return FFI::Pointer.new(value) if value.is_a?(Integer)

      raise ArgumentError, 'context must be an FFI::Pointer or integer address'
    end

    def self.ensure_native_function!(function_name, api_name)
      return if Native.function_available?(function_name)

      raise UnsupportedOperationError,
            "Surface#{api_name} is not supported by the current libSkiaSharp (missing #{function_name})"
    end

    def self.yield_surface(surface)
      return surface unless block_given?

      begin
        yield surface
      ensure
        surface.close
      end
    end
    private_class_method :yield_surface

    def detect_format_from_path(path)
      case File.extname(path).downcase
      when '.png'
        :png
      when '.jpg', '.jpeg'
        :jpeg
      when '.webp'
        :webp
      else
        :png
      end
    end
  end
end
