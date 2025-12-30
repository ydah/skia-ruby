# frozen_string_literal: true

module Skia
  class Surface < Base
    attr_reader :width, :height

    def initialize(ptr, width, height)
      super(ptr, :sk_surface_unref)
      @width = width
      @height = height
    end

    def self.make_raster(width, height, color_type: :rgba_8888, alpha_type: :premul)
      info = Native::SKImageInfo.new
      info[:width] = width
      info[:height] = height
      info[:colorType] = color_type
      info[:alphaType] = alpha_type
      info[:colorspace] = nil

      ptr = Native.sk_surface_new_raster(info, 0, nil)
      raise Error, 'Failed to create raster surface' if ptr.nil? || ptr.null?

      new(ptr, width, height)
    end

    def self.make_raster_direct(width, height, pixels, row_bytes, color_type: :rgba_8888, alpha_type: :premul)
      info = Native::SKImageInfo.new
      info[:width] = width
      info[:height] = height
      info[:colorType] = color_type
      info[:alphaType] = alpha_type
      info[:colorspace] = nil

      ptr = Native.sk_surface_new_raster_direct(info, pixels, row_bytes, nil, nil, nil)
      raise Error, 'Failed to create direct raster surface' if ptr.nil? || ptr.null?

      new(ptr, width, height)
    end

    def canvas
      @canvas ||= Canvas.new(Native.sk_surface_get_canvas(@ptr))
    end

    def snapshot
      ptr = Native.sk_surface_new_image_snapshot(@ptr)
      raise Error, 'Failed to create image snapshot' if ptr.nil? || ptr.null?

      Image.new(ptr)
    end

    def draw
      yield canvas
      self
    end

    def encode(format = :png, quality = 100)
      pixmap = Native.sk_pixmap_new
      raise Error, 'Failed to create pixmap' if pixmap.nil? || pixmap.null?

      begin
        raise Error, 'Failed to peek pixels from surface' unless Native.sk_surface_peek_pixels(@ptr, pixmap)

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
