# frozen_string_literal: true

module Skia
  class RuntimeEffect < Base
    def initialize(ptr)
      super(ptr, :sk_runtimeeffect_unref)
    end

    def self.make_for_shader(sksl)
      compile(sksl, :sk_runtimeeffect_make_for_shader, '.make_for_shader')
    end

    def self.make_for_color_filter(sksl)
      compile(sksl, :sk_runtimeeffect_make_for_color_filter, '.make_for_color_filter')
    end

    def self.make_for_blender(sksl)
      compile(sksl, :sk_runtimeeffect_make_for_blender, '.make_for_blender')
    end

    def self.compile(sksl, function_name, api_name)
      ensure_native_function!(function_name, api_name)
      ensure_native_function!(:sk_runtimeeffect_unref, api_name)
      source = sk_string_from(sksl)
      error = Native.sk_string_new_empty
      raise Error, 'Failed to allocate runtime effect error string' if error.nil? || error.null?

      begin
        ptr = Native.send(function_name, source, error)
        error_text = read_sk_string(error)
        raise Error, "Failed to compile runtime effect: #{error_text}" if ptr.nil? || ptr.null?

        new(ptr)
      ensure
        Native.sk_string_destructor(source) if source && !source.null?
        Native.sk_string_destructor(error) if error && !error.null?
      end
    end
    private_class_method :compile

    def make_shader(uniforms: nil, children: [], matrix: nil)
      ensure_native_function!(:sk_runtimeeffect_make_shader, '#make_shader')
      uniforms_data = coerce_uniform_data(uniforms)
      matrix_struct = matrix&.to_struct
      child_ptr = coerce_children(children)
      ptr = Native.sk_runtimeeffect_make_shader(@ptr, uniforms_data&.ptr, child_ptr, children.length, matrix_struct)
      raise Error, 'Failed to create shader from runtime effect' if ptr.nil? || ptr.null?

      Shader.new(ptr)
    end

    def make_color_filter(uniforms: nil, children: [])
      ensure_native_function!(:sk_runtimeeffect_make_color_filter, '#make_color_filter')
      uniforms_data = coerce_uniform_data(uniforms)
      ptr = Native.sk_runtimeeffect_make_color_filter(
        @ptr, uniforms_data&.ptr, coerce_children(children), children.length
      )
      raise Error, 'Failed to create color filter from runtime effect' if ptr.nil? || ptr.null?

      ColorFilter.new(ptr)
    end

    def make_blender(uniforms: nil, children: [])
      ensure_native_function!(:sk_runtimeeffect_make_blender, '#make_blender')
      uniforms_data = coerce_uniform_data(uniforms)
      ptr = Native.sk_runtimeeffect_make_blender(@ptr, uniforms_data&.ptr, coerce_children(children), children.length)
      raise Error, 'Failed to create blender from runtime effect' if ptr.nil? || ptr.null?

      Blender.new(ptr)
    end

    def uniform_byte_size
      ensure_native_function!(:sk_runtimeeffect_get_uniform_byte_size, '#uniform_byte_size')
      Native.sk_runtimeeffect_get_uniform_byte_size(@ptr)
    end

    def uniform_names
      native_names(:sk_runtimeeffect_get_uniforms_size, :sk_runtimeeffect_get_uniform_name, '#uniform_names')
    end

    def child_names
      native_names(:sk_runtimeeffect_get_children_size, :sk_runtimeeffect_get_child_name, '#child_names')
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

    def coerce_children(children)
      return nil if children.empty?
      unless children.all? { |child| child.nil? || child.is_a?(Base) }
        raise ArgumentError, 'children must contain Skia native objects or nil'
      end

      pointer = FFI::MemoryPointer.new(:pointer, children.length)
      pointer.write_array_of_pointer(children.map { |child| child&.ptr || FFI::Pointer::NULL })
      pointer
    end

    def native_names(size_function, name_function, api_name)
      ensure_native_function!(size_function, api_name)
      ensure_native_function!(name_function, api_name)
      count = Native.send(size_function, @ptr)
      Array.new(count) do |index|
        string = Native.sk_string_new_empty
        begin
          Native.send(name_function, @ptr, index, string)
          self.class.send(:read_sk_string, string)
        ensure
          Native.sk_string_destructor(string)
        end
      end
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
