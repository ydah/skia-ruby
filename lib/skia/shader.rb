# frozen_string_literal: true

module Skia
  class Shader < Base
    def initialize(ptr)
      super(ptr, :sk_shader_unref)
    end

    def self.wrap(ptr)
      return nil if ptr.nil? || ptr.null?

      new(ptr)
    end

    def self.linear_gradient(start_point, end_point, colors, positions = nil, tile_mode: :clamp, matrix: nil)
      points = FFI::MemoryPointer.new(Native::SKPoint, 2)
      start_struct = start_point.to_struct
      end_struct = end_point.to_struct
      points[0].write_bytes(start_struct.to_ptr.read_bytes(Native::SKPoint.size))
      points[1].write_bytes(end_struct.to_ptr.read_bytes(Native::SKPoint.size))

      color_values = colors.map { |c| c.is_a?(Color) ? c.to_i : c }
      colors_ptr = FFI::MemoryPointer.new(:uint32, color_values.size)
      colors_ptr.write_array_of_uint32(color_values)

      positions_ptr = nil
      if positions
        positions_ptr = FFI::MemoryPointer.new(:float, positions.size)
        positions_ptr.write_array_of_float(positions.map(&:to_f))
      end

      matrix_ptr = matrix&.to_struct

      ptr = Native.sk_shader_new_linear_gradient(
        points,
        colors_ptr,
        positions_ptr,
        color_values.size,
        tile_mode,
        matrix_ptr
      )
      raise Error, 'Failed to create linear gradient shader' if ptr.nil? || ptr.null?

      new(ptr)
    end

    def self.radial_gradient(center, radius, colors, positions = nil, tile_mode: :clamp, matrix: nil)
      center_struct = center.to_struct

      color_values = colors.map { |c| c.is_a?(Color) ? c.to_i : c }
      colors_ptr = FFI::MemoryPointer.new(:uint32, color_values.size)
      colors_ptr.write_array_of_uint32(color_values)

      positions_ptr = nil
      if positions
        positions_ptr = FFI::MemoryPointer.new(:float, positions.size)
        positions_ptr.write_array_of_float(positions.map(&:to_f))
      end

      matrix_ptr = matrix&.to_struct

      ptr = Native.sk_shader_new_radial_gradient(
        center_struct,
        radius.to_f,
        colors_ptr,
        positions_ptr,
        color_values.size,
        tile_mode,
        matrix_ptr
      )
      raise Error, 'Failed to create radial gradient shader' if ptr.nil? || ptr.null?

      new(ptr)
    end

    def self.sweep_gradient(center, colors, positions = nil, tile_mode: :clamp, start_angle: 0.0, end_angle: 360.0,
                            matrix: nil)
      center_struct = center.to_struct

      color_values = colors.map { |c| c.is_a?(Color) ? c.to_i : c }
      colors_ptr = FFI::MemoryPointer.new(:uint32, color_values.size)
      colors_ptr.write_array_of_uint32(color_values)

      positions_ptr = nil
      if positions
        positions_ptr = FFI::MemoryPointer.new(:float, positions.size)
        positions_ptr.write_array_of_float(positions.map(&:to_f))
      end

      matrix_ptr = matrix&.to_struct

      ptr = Native.sk_shader_new_sweep_gradient(
        center_struct,
        colors_ptr,
        positions_ptr,
        color_values.size,
        tile_mode,
        start_angle.to_f,
        end_angle.to_f,
        matrix_ptr
      )
      raise Error, 'Failed to create sweep gradient shader' if ptr.nil? || ptr.null?

      new(ptr)
    end
  end
end
