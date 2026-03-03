# frozen_string_literal: true

module Skia
  module Native
    extend FFI::Library
    @optional_functions = {}

    class << self
      attr_reader :optional_functions

      def platform_library_names
        case RUBY_PLATFORM
        when /darwin/
          ['libSkiaSharp.dylib', ['libskia.dylib'], 'darwin']
        when /linux/
          ['libSkiaSharp.so', ['libskia.so'], 'linux']
        when /mingw|mswin/
          ['libSkiaSharp.dll', ['skia.dll'], 'windows']
        else
          raise "Unsupported platform: #{RUBY_PLATFORM}"
        end
      end

      def normalize_library_path(path, lib_name)
        return nil if path.nil? || path.empty?

        File.directory?(path) ? File.join(path, lib_name) : path
      end

      def prebuilt_candidates(gem_root, platform_key, lib_name)
        [
          normalize_library_path(ENV['SKIA_PREBUILT_DIR'], lib_name),
          File.join(gem_root, 'vendor', 'native', platform_key, lib_name),
          File.join(gem_root, 'vendor', 'native', lib_name)
        ]
      end

      def find_library
        lib_name, fallbacks, platform_key = platform_library_names
        gem_root = File.expand_path('../..', __dir__)
        source = ENV.fetch('SKIA_NATIVE_SOURCE', 'auto').downcase
        explicit_path = normalize_library_path(ENV['SKIA_LIBRARY_PATH'], lib_name)

        search_paths =
          case source
          when 'local'
            [
              explicit_path,
              File.join(gem_root, lib_name),
              File.join(Dir.pwd, lib_name)
            ]
          when 'prebuilt'
            prebuilt_candidates(gem_root, platform_key, lib_name)
          when 'auto'
            [
              explicit_path,
              File.join(gem_root, lib_name),
              File.join(Dir.pwd, lib_name),
              *prebuilt_candidates(gem_root, platform_key, lib_name),
              lib_name
            ]
          else
            raise ArgumentError,
                  "Invalid SKIA_NATIVE_SOURCE='#{source}'. Use one of: auto, local, prebuilt"
          end

        found = search_paths.compact.uniq.find { |path| File.file?(path) }
        return found if found

        if source == 'local'
          raise LoadError,
                'SKIA_NATIVE_SOURCE=local but no local library found. ' \
                "Set SKIA_LIBRARY_PATH to '#{lib_name}' or a directory containing it."
        end

        [lib_name, *fallbacks]
      end

      def optional_attach_function(name, args, ret)
        attach_function(name, args, ret)
        @optional_functions[name.to_sym] = true
      rescue FFI::NotFoundError
        @optional_functions[name.to_sym] = false
      end

      def function_available?(name)
        key = name.to_sym
        return @optional_functions[key] if @optional_functions.key?(key)

        respond_to?(key)
      end
    end

    ffi_lib_flags :now, :global

    begin
      lib_path = find_library
      ffi_lib(*Array(lib_path))
    rescue LoadError => e
      warn 'Failed to load Skia library. Please ensure libSkiaSharp is installed.'
      warn 'Download from: https://www.nuget.org/packages/SkiaSharp.NativeAssets.macOS'
      raise e
    end

    require_relative 'native/types'
    require_relative 'native/functions'
    require_relative 'native/callbacks'
  end
end
