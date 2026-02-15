# frozen_string_literal: true

module Skia
  class Data < Base
    def initialize(ptr_or_bytes = nil)
      case ptr_or_bytes
      when FFI::Pointer
        super(ptr_or_bytes, :sk_data_unref)
      when String
        ptr = Native.sk_data_new_with_copy(ptr_or_bytes, ptr_or_bytes.bytesize)
        raise Error, 'Failed to create data from bytes' if ptr.nil? || ptr.null?

        super(ptr, :sk_data_unref)
      when nil
        raise ArgumentError, 'Data requires bytes or pointer'
      else
        raise ArgumentError, "Invalid argument type: #{ptr_or_bytes.class}"
      end
    end

    def self.from_file(path)
      ptr = Native.sk_data_new_from_file(path)
      raise FileNotFoundError, "Failed to load file: #{path}" if ptr.nil? || ptr.null?

      new(ptr)
    end

    def self.from_bytes(bytes)
      new(bytes)
    end

    def size
      Native.sk_data_get_size(@ptr)
    end

    def empty?
      size == 0
    end

    def to_s
      data_ptr = Native.sk_data_get_data(@ptr)
      data_ptr.read_bytes(size)
    end

    alias to_bytes to_s
  end
end
