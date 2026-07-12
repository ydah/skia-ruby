# frozen_string_literal: true

module Skia
  class PathMeasure < Base
    def initialize(path = nil, force_closed: false, res_scale: 1.0)
      raise ArgumentError, 'path must be a Skia::Path or nil' unless path.nil? || path.is_a?(Path)

      native_ptr = if path
                     Native.sk_pathmeasure_new_with_path(path.ptr, force_closed, res_scale.to_f)
                   else
                     Native.sk_pathmeasure_new
                   end
      super(native_ptr, :sk_pathmeasure_destroy, owner: path)
    end

    def length
      Native.sk_pathmeasure_get_length(@ptr)
    end

    def contour_closed?
      Native.sk_pathmeasure_is_closed(@ptr)
    end

    def path=(value)
      set_path(value)
    end

    def set_path(path, force_closed: false)
      raise ArgumentError, 'path must be a Skia::Path or nil' unless path.nil? || path.is_a?(Path)

      Native.sk_pathmeasure_set_path(@ptr, path&.ptr, force_closed)
      @owner = path
      self
    end

    def position_tangent(distance)
      position = Native::SKPoint.new
      tangent = Native::SKPoint.new
      return nil unless Native.sk_pathmeasure_get_pos_tan(@ptr, distance.to_f, position, tangent)

      [Point.from_struct(position), Point.from_struct(tangent)]
    end

    def position(distance)
      point = Native::SKPoint.new
      return nil unless Native.sk_pathmeasure_get_pos_tan(@ptr, distance.to_f, point, nil)

      Point.from_struct(point)
    end

    def tangent(distance)
      point = Native::SKPoint.new
      return nil unless Native.sk_pathmeasure_get_pos_tan(@ptr, distance.to_f, nil, point)

      Point.from_struct(point)
    end

    def matrix(distance, flags: :position_and_tangent)
      matrix = Native::SKMatrix.new
      return nil unless Native.sk_pathmeasure_get_matrix(@ptr, distance.to_f, matrix, flags)

      Matrix.from_struct(matrix)
    end

    def next_contour
      Native.sk_pathmeasure_next_contour(@ptr)
    end
  end
end
