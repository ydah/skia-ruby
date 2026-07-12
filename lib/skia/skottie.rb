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

      def ensure_function!(function_name, api_name)
        register_native_symbols!
        return if Native.function_available?(function_name)

        raise UnsupportedOperationError,
              "Skottie#{api_name} is not supported by the current libSkiaSharp (missing #{function_name})"
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
        Native.optional_attach_function :skottie_animation_builder_new, [:uint32], :pointer
        Native.optional_attach_function :skottie_animation_builder_delete, [:pointer], :void
        Native.optional_attach_function :skottie_animation_builder_set_font_manager, %i[pointer sk_fontmgr_t], :void
        Native.optional_attach_function :skottie_animation_builder_set_resource_provider, %i[pointer pointer], :void
        Native.optional_attach_function :skottie_animation_builder_make_from_string, %i[pointer string size_t], :pointer
        Native.optional_attach_function :skottie_animation_builder_make_from_file, %i[pointer string], :pointer
        Native.optional_attach_function :skresources_file_resource_provider_make, %i[sk_string_t bool], :pointer
        Native.optional_attach_function :skresources_data_uri_resource_provider_proxy_make, %i[pointer bool], :pointer
        Native.optional_attach_function :skresources_caching_resource_provider_proxy_make, [:pointer], :pointer
        Native.optional_attach_function :skresources_resource_provider_load, %i[pointer string string], :sk_data_t
        Native.optional_attach_function :skresources_resource_provider_unref, [:pointer], :void

        @native_symbols_registered = true
      end
    end

    class Animation < Base
      def initialize(ptr, owner: nil)
        super(ptr, :skottie_animation_unref, owner: owner)
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

    class ResourceProvider < Base
      def initialize(ptr, owner: nil)
        raise Error, 'Failed to create resource provider' if ptr.nil? || ptr.null?

        super(ptr, :skresources_resource_provider_unref, owner: owner)
      end

      def self.file(base_directory, predecode: false)
        Skottie.ensure_function!(:skresources_file_resource_provider_make, '::ResourceProvider.file')
        native_string = string_from(base_directory)
        begin
          new(Native.skresources_file_resource_provider_make(native_string, predecode))
        ensure
          Native.sk_string_destructor(native_string)
        end
      end

      def self.data_uri(fallback: nil, predecode: false)
        Skottie.ensure_function!(:skresources_data_uri_resource_provider_proxy_make, '::ResourceProvider.data_uri')
        raise ArgumentError, 'fallback must be a Skottie::ResourceProvider or nil' unless fallback.nil? || fallback.is_a?(ResourceProvider)

        ptr = Native.skresources_data_uri_resource_provider_proxy_make(fallback&.ptr, predecode)
        new(ptr, owner: fallback)
      end

      def cached
        Skottie.ensure_function!(:skresources_caching_resource_provider_proxy_make, '::ResourceProvider#cached')
        self.class.new(Native.skresources_caching_resource_provider_proxy_make(@ptr), owner: self)
      end

      def load(name, path: '')
        Skottie.ensure_function!(:skresources_resource_provider_load, '::ResourceProvider#load')
        ptr = Native.skresources_resource_provider_load(@ptr, path.to_s, name.to_s)
        return nil if ptr.nil? || ptr.null?

        Data.new(ptr)
      end

      def self.string_from(value)
        bytes = value.to_s.b
        buffer = FFI::MemoryPointer.new(:char, bytes.bytesize)
        buffer.put_bytes(0, bytes)
        ptr = Native.sk_string_new_with_copy(buffer, bytes.bytesize)
        raise Error, 'Failed to allocate native string' if ptr.nil? || ptr.null?

        ptr
      end
      private_class_method :string_from
    end

    class AnimationBuilder < Base
      FLAGS = {
        defer_image_loading: 1,
        prefer_embedded_fonts: 2
      }.freeze

      def initialize(flags: [])
        Skottie.ensure_function!(:skottie_animation_builder_new, '::AnimationBuilder.new')
        ptr = Native.skottie_animation_builder_new(flag_value(flags))
        raise Error, 'Failed to create skottie animation builder' if ptr.nil? || ptr.null?

        super(ptr, :skottie_animation_builder_delete)
        @references = []
      end

      def font_manager=(manager)
        raise ArgumentError, 'font manager must be a Skia::FontManager' unless manager.is_a?(FontManager)

        Skottie.ensure_function!(:skottie_animation_builder_set_font_manager, '::AnimationBuilder#font_manager=')
        Native.skottie_animation_builder_set_font_manager(@ptr, manager.ptr)
        @references << manager
      end

      def resource_provider=(provider)
        raise ArgumentError, 'resource provider must be a Skottie::ResourceProvider' unless provider.is_a?(ResourceProvider)

        Skottie.ensure_function!(:skottie_animation_builder_set_resource_provider, '::AnimationBuilder#resource_provider=')
        Native.skottie_animation_builder_set_resource_provider(@ptr, provider.ptr)
        @references << provider
      end

      def build_json(json)
        Skottie.ensure_function!(:skottie_animation_builder_make_from_string, '::AnimationBuilder#build_json')
        source = json.to_s
        ptr = Native.skottie_animation_builder_make_from_string(@ptr, source, source.bytesize)
        build_animation(ptr, 'JSON')
      end

      def build_file(path)
        Skottie.ensure_function!(:skottie_animation_builder_make_from_file, '::AnimationBuilder#build_file')
        ptr = Native.skottie_animation_builder_make_from_file(@ptr, path.to_s)
        build_animation(ptr, path)
      end

      private

      def flag_value(flags)
        return flags if flags.is_a?(Integer)

        Array(flags).reduce(0) do |value, flag|
          bit = FLAGS.fetch(flag) { raise ArgumentError, "unknown animation builder flag: #{flag}" }
          value | bit
        end
      end

      def build_animation(ptr, source)
        raise Error, "Failed to create skottie animation from #{source}" if ptr.nil? || ptr.null?

        Animation.new(ptr, owner: @references.dup)
      end
    end
  end
end
