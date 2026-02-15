# frozen_string_literal: true

module Skia
  class RuntimeEffect < Base
    def initialize(ptr)
      super(ptr, :sk_runtimeeffect_unref)
    end

    def self.make_for_shader(sksl)
      ensure_runtimeeffect_available!
      source = sk_string_from(sksl)
      error = Native.sk_string_new_empty
      raise Error, 'Failed to allocate runtime effect error string' if error.nil? || error.null?

      begin
        ptr = Native.sk_runtimeeffect_make_for_shader(source, error)
        error_text = read_sk_string(error)
        raise Error, "Failed to compile runtime shader: #{error_text}" if ptr.nil? || ptr.null?

        new(ptr)
      ensure
        Native.sk_string_destructor(source) if source && !source.null?
        Native.sk_string_destructor(error) if error && !error.null?
      end
    end

    def make_shader(uniforms: nil, matrix: nil)
      ensure_native_function!(:sk_runtimeeffect_make_shader, '#make_shader')
      uniforms_data = coerce_uniform_data(uniforms)
      matrix_struct = matrix&.to_struct
      ptr = Native.sk_runtimeeffect_make_shader(@ptr, uniforms_data&.ptr, nil, 0, matrix_struct)
      raise Error, 'Failed to create shader from runtime effect' if ptr.nil? || ptr.null?

      Shader.new(ptr)
    end

    private

    def self.sk_string_from(value)
      bytes = value.to_s.b
      buffer = FFI::MemoryPointer.new(:char, bytes.bytesize)
      buffer.put_bytes(0, bytes)
      ptr = Native.sk_string_new_with_copy(buffer, bytes.bytesize)
      raise Error, 'Failed to allocate native string' if ptr.nil? || ptr.null?

      ptr
    end

    def self.read_sk_string(ptr)
      return '' if ptr.nil? || ptr.null?

      cstr = Native.sk_string_get_c_str(ptr)
      size = Native.sk_string_get_size(ptr)
      return '' if cstr.nil? || cstr.null? || size.to_i.zero?

      cstr.read_string(size)
    end

    def coerce_uniform_data(value)
      case value
      when nil
        nil
      when Data
        value
      when String
        Data.new(value)
      else
        raise ArgumentError, 'uniforms must be Skia::Data, String, or nil'
      end
    end

    def self.ensure_runtimeeffect_available!
      ensure_native_function!(:sk_runtimeeffect_make_for_shader, '.make_for_shader')
      ensure_native_function!(:sk_runtimeeffect_unref, '.make_for_shader')
    end

    def ensure_native_function!(function_name, api_name)
      self.class.ensure_native_function!(function_name, api_name)
    end

    def self.ensure_native_function!(function_name, api_name)
      return if Native.function_available?(function_name)

      raise UnsupportedOperationError,
            "RuntimeEffect#{api_name} is not supported by the current libSkiaSharp (missing #{function_name})"
    end
  end
end
