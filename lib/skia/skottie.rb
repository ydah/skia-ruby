# frozen_string_literal: true

module Skia
  module Skottie
    REQUIRED_NATIVE_SYMBOLS = %i[
      skottie_animation_make_from_string
      skottie_animation_unref
      skottie_animation_seek_frame
      skottie_animation_render
    ].freeze

    class << self
      def available?
        missing_symbols.empty?
      end

      def missing_symbols
        register_native_symbols!
        REQUIRED_NATIVE_SYMBOLS.reject { |name| Native.function_available?(name) }
      end

      def ensure_available!(api_name = '')
        missing = missing_symbols
        return if missing.empty?

        raise UnsupportedOperationError,
              "Skottie#{api_name} is not supported by the current libSkiaSharp (missing #{missing.join(', ')})"
      end

      private

      def register_native_symbols!
        return if @native_symbols_registered

        Native.optional_attach_function :skottie_animation_make_from_string, %i[string int], :pointer
        Native.optional_attach_function :skottie_animation_make_from_file, [:string], :pointer
        Native.optional_attach_function :skottie_animation_make_from_data, %i[pointer size_t], :pointer
        Native.optional_attach_function :skottie_animation_ref, [:pointer], :void
        Native.optional_attach_function :skottie_animation_unref, [:pointer], :void
        Native.optional_attach_function :skottie_animation_seek, %i[pointer float pointer], :void
        Native.optional_attach_function :skottie_animation_seek_frame, %i[pointer float pointer], :void
        Native.optional_attach_function :skottie_animation_seek_frame_time, %i[pointer float pointer], :void
        Native.optional_attach_function :skottie_animation_render, [:pointer, :sk_canvas_t, Native::SKRect.ptr], :void
        Native.optional_attach_function :skottie_animation_get_duration, [:pointer], :double
        Native.optional_attach_function :skottie_animation_get_fps, [:pointer], :double
        Native.optional_attach_function :skottie_animation_get_in_point, [:pointer], :double
        Native.optional_attach_function :skottie_animation_get_out_point, [:pointer], :double
        Native.optional_attach_function :skottie_animation_get_size, [:pointer, Native::SKSize.ptr], :void
        Native.optional_attach_function :skottie_animation_get_version, %i[pointer sk_string_t], :void

        @native_symbols_registered = true
      end
    end

    class Animation < Base
      def initialize(ptr)
        super(ptr, :skottie_animation_unref)
      end

      def self.make_from_json(json)
        Skottie.ensure_available!('.Animation.make_from_json')

        source = json.to_s
        ptr = Native.skottie_animation_make_from_string(source, source.bytesize)
        raise Error, 'Failed to create skottie animation from JSON' if ptr.nil? || ptr.null?

        new(ptr)
      end

      def self.make_from_file(path)
        Skottie.ensure_available!('.Animation.make_from_file')
        ensure_native_function!(:skottie_animation_make_from_file, '.Animation.make_from_file')

        ptr = Native.skottie_animation_make_from_file(path.to_s)
        raise Error, "Failed to create skottie animation from file: #{path}" if ptr.nil? || ptr.null?

        new(ptr)
      end

      def size
        ensure_native_function!(:skottie_animation_get_size, '#size')

        size_struct = Native::SKSize.new
        Native.skottie_animation_get_size(@ptr, size_struct)
        [size_struct[:width], size_struct[:height]]
      end

      def duration
        ensure_native_function!(:skottie_animation_get_duration, '#duration')
        Native.skottie_animation_get_duration(@ptr)
      end

      def fps
        ensure_native_function!(:skottie_animation_get_fps, '#fps')
        Native.skottie_animation_get_fps(@ptr)
      end

      def in_point
        ensure_native_function!(:skottie_animation_get_in_point, '#in_point')
        Native.skottie_animation_get_in_point(@ptr)
      end

      def out_point
        ensure_native_function!(:skottie_animation_get_out_point, '#out_point')
        Native.skottie_animation_get_out_point(@ptr)
      end

      def version
        ensure_native_function!(:skottie_animation_get_version, '#version')

        str = Native.sk_string_new_empty
        raise Error, 'Failed to allocate skottie version string' if str.nil? || str.null?

        begin
          Native.skottie_animation_get_version(@ptr, str)
          self.class.read_sk_string(str)
        ensure
          Native.sk_string_destructor(str) if str && !str.null?
        end
      end

      def seek(t)
        ensure_native_function!(:skottie_animation_seek, '#seek')
        Native.skottie_animation_seek(@ptr, t.to_f, nil)
        self
      end

      def seek_frame(frame)
        ensure_native_function!(:skottie_animation_seek_frame, '#seek_frame')
        Native.skottie_animation_seek_frame(@ptr, frame.to_f, nil)
        self
      end

      def seek_frame_time(seconds)
        ensure_native_function!(:skottie_animation_seek_frame_time, '#seek_frame_time')
        Native.skottie_animation_seek_frame_time(@ptr, seconds.to_f, nil)
        self
      end

      def render(canvas, rect = nil)
        ensure_native_function!(:skottie_animation_render, '#render')

        draw_rect = rect || begin
          width, height = size
          Rect.from_wh(width, height)
        end

        Native.skottie_animation_render(@ptr, canvas.ptr, draw_rect.to_struct)
        self
      end

      def render_frame(canvas, frame:, rect: nil)
        seek_frame(frame)
        render(canvas, rect)
      end

      private

      def ensure_native_function!(function_name, api_name)
        self.class.ensure_native_function!(function_name, api_name)
      end

      def self.ensure_native_function!(function_name, api_name)
        return if Native.function_available?(function_name)

        raise UnsupportedOperationError,
              "Skottie::Animation#{api_name} is not supported by the current libSkiaSharp (missing #{function_name})"
      end

      def self.read_sk_string(ptr)
        return '' if ptr.nil? || ptr.null?

        cstr = Native.sk_string_get_c_str(ptr)
        size = Native.sk_string_get_size(ptr)
        return '' if cstr.nil? || cstr.null? || size.to_i.zero?

        cstr.read_string(size)
      end
    end
  end
end
