# frozen_string_literal: true

module Skia
  class Vertices < Base
    def initialize(ptr)
      super(ptr, :sk_vertices_unref)
    end

    def self.make_copy(mode, positions, texture_coords: nil, colors: nil, indices: nil)
      raise ArgumentError, 'positions cannot be empty' if positions.empty?
      if texture_coords && texture_coords.length != positions.length
        raise ArgumentError, 'texture_coords and positions must have the same length'
      end
      raise ArgumentError, 'colors and positions must have the same length' if colors && colors.length != positions.length

      position_ptr = point_array(positions)
      texture_ptr = point_array(texture_coords)
      color_ptr = color_array(colors)
      index_ptr = index_array(indices, positions.length)
      ptr = Native.sk_vertices_make_copy(
        mode, positions.length, position_ptr, texture_ptr, color_ptr, indices ? indices.length : 0, index_ptr
      )
      raise Error, 'Failed to create vertices' if ptr.nil? || ptr.null?

      new(ptr)
    end

    def self.point_array(points)
      return nil if points.nil?

      pointer = FFI::MemoryPointer.new(Native::SKPoint, points.length)
      points.each_with_index do |point, index|
        value = point.is_a?(Point) ? point : Point.new(*point)
        destination = Native::SKPoint.new(pointer + (index * Native::SKPoint.size))
        destination.to_ptr.write_bytes(value.to_struct.to_ptr.read_bytes(Native::SKPoint.size))
      end
      pointer
    end
    private_class_method :point_array

    def self.color_array(colors)
      return nil if colors.nil?

      values = colors.map { |color| color.is_a?(Color) ? color.to_i : color }
      pointer = FFI::MemoryPointer.new(:uint32, values.length)
      pointer.write_array_of_uint32(values)
      pointer
    end
    private_class_method :color_array

    def self.index_array(indices, vertex_count)
      return nil if indices.nil?
      unless indices.all? { |index| index.is_a?(Integer) && index.between?(0, vertex_count - 1) && index <= 65_535 }
        raise ArgumentError, 'indices must reference existing vertices and fit in uint16'
      end

      pointer = FFI::MemoryPointer.new(:uint16, indices.length)
      pointer.write_array_of_uint16(indices)
      pointer
    end
    private_class_method :index_array
  end
end
