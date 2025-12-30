# frozen_string_literal: true

module Skia
  module Native
    extend FFI::Library

    class << self
      def find_library
        lib_name, fallbacks = case RUBY_PLATFORM
                              when /darwin/
                                ['libSkiaSharp.dylib', ['libskia.dylib']]
                              when /linux/
                                ['libSkiaSharp.so', ['libskia.so']]
                              when /mingw|mswin/
                                ['libSkiaSharp.dll', ['skia.dll']]
                              else
                                raise "Unsupported platform: #{RUBY_PLATFORM}"
                              end

        gem_root = File.expand_path('../..', __dir__)
        search_paths = [
          File.join(gem_root, lib_name),
          File.join(Dir.pwd, lib_name),
          ENV['SKIA_LIBRARY_PATH'],
          lib_name
        ].compact

        found = search_paths.find { |p| File.exist?(p) }
        return found if found

        [lib_name] + fallbacks
      end
    end

    ffi_lib_flags :now, :global

    begin
      lib_path = find_library
      ffi_lib Array(lib_path).first
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
