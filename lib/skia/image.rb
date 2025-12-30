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

    def width
      Native.sk_image_get_width(@ptr)
    end

    def height
      Native.sk_image_get_height(@ptr)
    end

    def unique_id
      Native.sk_image_get_unique_id(@ptr)
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
