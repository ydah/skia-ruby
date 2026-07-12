# frozen_string_literal: true

module Skia
  class Codec < Base
    FrameInfo = Struct.new(
      :required_frame, :duration, :fully_received, :alpha_type, :has_alpha_within_bounds,
      :disposal_method, :blend, :rect,
      keyword_init: true
    )

    def initialize(ptr, owner: nil)
      super(ptr, :sk_codec_destroy, owner: owner)
    end

    def self.from_file(path)
      from_data(Data.from_file(path))
    end

    def self.from_data(data)
      data_object = data.is_a?(Data) ? data : Data.new(data)
      ptr = Native.sk_codec_new_from_data(data_object.ptr)
      raise DecodingError, 'Failed to create image codec' if ptr.nil? || ptr.null?

      new(ptr, owner: data_object)
    end

    def info
      native_info = Native::SKImageInfo.new
      Native.sk_codec_get_info(@ptr, native_info)
      ImageInfo.from_struct(native_info)
    end

    def origin
      Native.sk_codec_get_origin(@ptr)
    end

    def format
      Native.sk_codec_get_encoded_format(@ptr)
    end

    def frame_count
      count = Native.sk_codec_get_frame_count(@ptr)
      count.positive? ? count : 1
    end

    def repetition_count
      Native.sk_codec_get_repetition_count(@ptr)
    end

    def frame_info(index)
      validate_frame_index!(index)
      native_info = Native::SKCodecFrameInfo.new
      return nil unless Native.sk_codec_get_frame_info_for_index(@ptr, index, native_info)

      FrameInfo.new(
        required_frame: native_info[:requiredFrame],
        duration: native_info[:duration],
        fully_received: native_info[:fullyReceived] != 0,
        alpha_type: native_info[:alphaType],
        has_alpha_within_bounds: native_info[:hasAlphaWithinBounds] != 0,
        disposal_method: native_info[:disposalMethod],
        blend: native_info[:blend],
        rect: IRect.from_struct(native_info[:frameRect])
      )
    end

    def frame_infos
      Array.new(frame_count) { |index| frame_info(index) }
    end

    def decode_frame(index = 0, image_info: nil, apply_orientation: true)
      validate_frame_index!(index)
      decode_frames(image_info: image_info, limit: index + 1, apply_orientation: apply_orientation).fetch(index)
    end

    def decode_frames(image_info: nil, limit: frame_count, apply_orientation: true)
      output_info = decode_info(image_info)
      row_bytes = output_info.min_row_bytes
      pixels = FFI::MemoryPointer.new(:uint8, row_bytes * output_info.height, true)
      count = [Integer(limit), frame_count].min

      Array.new(count) do |index|
        decode_into(pixels, output_info, row_bytes, frame_index: index, prior_frame: index - 1)
        bytes = pixels.read_bytes(row_bytes * output_info.height)
        if apply_orientation && origin != :top_left
          oriented_info, bytes = orient(output_info, bytes)
          image_from_pixels(oriented_info, bytes, oriented_info.min_row_bytes)
        else
          image_from_pixels(output_info, bytes, row_bytes)
        end
      end
    end

    private

    def validate_frame_index!(index)
      position = Integer(index)
      raise IndexError, "frame index out of range: #{position}" unless position.between?(0, frame_count - 1)
    end

    def decode_info(value)
      return value if value.is_a?(ImageInfo)
      raise ArgumentError, 'image_info must be a Skia::ImageInfo or nil' unless value.nil?

      source = info
      ImageInfo.new(width: source.width, height: source.height, color_type: :rgba_8888, alpha_type: :premul,
                    color_space: source.color_space)
    end

    def decode_into(pixels, output_info, row_bytes, frame_index:, prior_frame:)
      options = Native::SKCodecOptions.new
      options[:zeroInitialized] = :yes
      options[:subset] = nil
      options[:frameIndex] = frame_index
      options[:priorFrame] = prior_frame
      options[:maxDecodeMemory] = 0
      result = Native.sk_codec_get_pixels(@ptr, output_info.to_struct, pixels, row_bytes, options)
      return if %i[success incomplete_input].include?(result)

      raise DecodingError, "Failed to decode frame #{frame_index}: #{result}"
    end

    def image_from_pixels(output_info, bytes, row_bytes)
      surface = Surface.make_raster_direct(image_info: output_info, pixels: bytes, row_bytes: row_bytes)
      begin
        surface.snapshot
      ensure
        surface.close
      end
    end

    def orient(source_info, source_bytes)
      encoded_origin = origin
      destination_info = oriented_info(source_info, encoded_origin)
      bytes_per_pixel = source_info.bytes_per_pixel
      destination = String.new(capacity: destination_info.min_row_bytes * destination_info.height, encoding: Encoding::BINARY)
      destination << ("\0" * (destination_info.min_row_bytes * destination_info.height))

      source_info.height.times do |y|
        source_info.width.times do |x|
          destination_x, destination_y = oriented_coordinates(x, y, source_info.width, source_info.height, encoded_origin)
          source_offset = ((y * source_info.width) + x) * bytes_per_pixel
          destination_offset = ((destination_y * destination_info.width) + destination_x) * bytes_per_pixel
          destination[destination_offset, bytes_per_pixel] = source_bytes.byteslice(source_offset, bytes_per_pixel)
        end
      end
      [destination_info, destination]
    end

    def oriented_info(source_info, encoded_origin)
      swap_dimensions = %i[left_top right_top right_bottom left_bottom].include?(encoded_origin)
      width, height = swap_dimensions ? [source_info.height, source_info.width] : [source_info.width, source_info.height]
      ImageInfo.new(width: width, height: height, color_type: source_info.color_type, alpha_type: source_info.alpha_type,
                    color_space: source_info.color_space)
    end

    def oriented_coordinates(x, y, width, height, encoded_origin)
      case encoded_origin
      when :top_right then [width - 1 - x, y]
      when :bottom_right then [width - 1 - x, height - 1 - y]
      when :bottom_left then [x, height - 1 - y]
      when :left_top then [y, x]
      when :right_top then [height - 1 - y, x]
      when :right_bottom then [height - 1 - y, width - 1 - x]
      when :left_bottom then [y, width - 1 - x]
      else [x, y]
      end
    end
  end
end
