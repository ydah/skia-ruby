# frozen_string_literal: true

module Skia
  class Image < Base
    def initialize(ptr)
      super(ptr, :sk_image_unref)
    end

    def self.from_file(path)
      data = Data.from_file(path)
      ptr = Native.sk_image_new_from_encoded(data.ptr)
      raise DecodingError, "Failed to decode image: #{path}" if ptr.nil? || ptr.null?

      new(ptr)
    end

    def self.from_data(data)
      data_obj = data.is_a?(Data) ? data : Data.new(data)
      ptr = Native.sk_image_new_from_encoded(data_obj.ptr)
      raise DecodingError, 'Failed to decode image data' if ptr.nil? || ptr.null?

      new(ptr)
    end

    def self.from_bitmap(bitmap)
      raise ArgumentError, 'bitmap must be a Skia::Bitmap' unless bitmap.is_a?(Bitmap)

      ptr = Native.sk_image_new_from_bitmap(bitmap.ptr)
      raise DecodingError, 'Failed to create image from bitmap' if ptr.nil? || ptr.null?

      new(ptr)
    end

    def width
      Native.sk_image_get_width(@ptr)
    end

    def height
      Native.sk_image_get_height(@ptr)
    end

    def unique_id
      Native.sk_image_get_unique_id(@ptr)
    end

    def color_type
      Native.sk_image_get_color_type(@ptr)
    end

    def alpha_type
      Native.sk_image_get_alpha_type(@ptr)
    end

    def color_space
      ColorSpace.wrap(Native.sk_image_get_colorspace(@ptr), retain: true)
    end

    def encoded_data
      ptr = Native.sk_image_ref_encoded(@ptr)
      return encode(:png) if ptr.nil? || ptr.null?

      Data.new(ptr)
    end

    def make_shader(tile_x: :clamp, tile_y: :clamp, sampling: SamplingOptions.default, matrix: nil)
      matrix_struct = matrix&.to_struct

      ptr = Native.sk_image_make_shader(@ptr, tile_x, tile_y, sampling.to_struct, matrix_struct)
      raise Error, 'Failed to create shader from image' if ptr.nil? || ptr.null?

      Shader.new(ptr)
    end

    def resize(width, height, sampling: SamplingOptions.linear)
      target_width = Integer(width)
      target_height = Integer(height)
      raise ArgumentError, 'width and height must be positive' unless target_width.positive? && target_height.positive?

      Surface.make_raster(target_width, target_height, color_type: color_type, alpha_type: alpha_type) do |surface|
        destination = Rect.from_wh(target_width, target_height)
        surface.canvas.draw_image_rect(self, nil, destination, sampling: sampling)
        surface.snapshot
      end
    end

    def scale(factor, sampling: SamplingOptions.linear)
      scale_factor = Float(factor)
      raise ArgumentError, 'factor must be positive' unless scale_factor.positive?

      resize((width * scale_factor).round, (height * scale_factor).round, sampling: sampling)
    end

    def subset(rect)
      rect_struct = rect.to_struct
      ptr = Native.sk_image_make_subset_raster(@ptr, rect_struct)
      return nil if ptr.nil? || ptr.null?

      self.class.new(ptr)
    end

    def read_pixels(width: nil, height: nil, src_x: 0, src_y: 0, row_bytes: nil, image_info: nil, color_type: :rgba_8888,
                    alpha_type: :premul, color_space: nil, caching_hint: :allow)
      info = image_info || ImageInfo.new(
        width: width || (self.width - src_x),
        height: height || (self.height - src_y),
        color_type: color_type,
        alpha_type: alpha_type,
        color_space: color_space
      )

      row_bytes ||= info.min_row_bytes
      byte_size = row_bytes * info.height
      pixels = FFI::MemoryPointer.new(:uint8, byte_size)

      success = Native.sk_image_read_pixels(@ptr, info.to_struct, pixels, row_bytes, src_x.to_i, src_y.to_i, caching_hint)
      raise DecodingError, 'Failed to read pixels from image' unless success

      pixels.read_bytes(byte_size)
    end

    def peek_pixels
      pixmap = Pixmap.new
      return nil unless Native.sk_image_peek_pixels(@ptr, pixmap.ptr)

      pixmap.send(:keep_alive, self)
      pixmap
    end

    def encode(format = :png, quality = 100)
      # Create a pixmap to hold the image pixels
      pixmap = Native.sk_pixmap_new
      raise EncodingError, 'Failed to create pixmap' if pixmap.nil? || pixmap.null?

      begin
        # Peek pixels from the image into the pixmap
        raise EncodingError, 'Failed to peek pixels from image' unless Native.sk_image_peek_pixels(@ptr, pixmap)

        stream = Native.sk_dynamicmemorywstream_new
        raise EncodingError, 'Failed to create stream' if stream.nil? || stream.null?

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

          raise EncodingError, "Failed to encode image as #{format}" unless success

          data_ptr = Native.sk_dynamicmemorywstream_detach_as_data(stream)
          raise EncodingError, 'Failed to get encoded data' if data_ptr.nil? || data_ptr.null?

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

    def detect_format_from_path(path)
      case File.extname(path).downcase
      when '.png'
        :png
      when '.jpg', '.jpeg'
        :jpeg
      when '.webp'
        :webp
      when '.gif'
        :gif
      when '.bmp'
        :bmp
      else
        :png
      end
    end
  end
end
