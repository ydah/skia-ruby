# frozen_string_literal: true

module Skia
  class Path < Base
    def initialize(ptr = nil)
      super(ptr || Native.sk_path_new, :sk_path_delete)
    end

    def self.build(&block)
      path = new
      path.instance_eval(&block) if block
      path
    end

    def move_to(x, y)
      Native.sk_path_move_to(@ptr, x.to_f, y.to_f)
      self
    end

    def line_to(x, y)
      Native.sk_path_line_to(@ptr, x.to_f, y.to_f)
      self
    end

    def quad_to(x1, y1, x2, y2)
      Native.sk_path_quad_to(@ptr, x1.to_f, y1.to_f, x2.to_f, y2.to_f)
      self
    end

    def conic_to(x1, y1, x2, y2, weight)
      Native.sk_path_conic_to(@ptr, x1.to_f, y1.to_f, x2.to_f, y2.to_f, weight.to_f)
      self
    end

    def cubic_to(x1, y1, x2, y2, x3, y3)
      Native.sk_path_cubic_to(@ptr, x1.to_f, y1.to_f, x2.to_f, y2.to_f, x3.to_f, y3.to_f)
      self
    end

    def arc_to(rx, ry, x_axis_rotate, x, y)
      Native.sk_path_arc_to(@ptr, rx.to_f, ry.to_f, x_axis_rotate.to_f, x.to_f, y.to_f)
      self
    end

    def arc_to_with_oval(oval, start_angle, sweep_angle, force_move_to = false)
      rect_struct = oval.to_struct
      Native.sk_path_arc_to_with_oval(@ptr, rect_struct, start_angle.to_f, sweep_angle.to_f, force_move_to)
      self
    end

    def close
      Native.sk_path_close(@ptr)
      self
    end

    def add_rect(rect, direction = :cw)
      rect_struct = rect.to_struct
      Native.sk_path_add_rect(@ptr, rect_struct, direction)
      self
    end

    def add_oval(rect, direction = :cw)
      rect_struct = rect.to_struct
      Native.sk_path_add_oval(@ptr, rect_struct, direction)
      self
    end

    def add_circle(cx, cy, radius, direction = :cw)
      Native.sk_path_add_circle(@ptr, cx.to_f, cy.to_f, radius.to_f, direction)
      self
    end

    def add_arc(rect, start_angle, sweep_angle)
      rect_struct = rect.to_struct
      Native.sk_path_add_arc(@ptr, rect_struct, start_angle.to_f, sweep_angle.to_f)
      self
    end

    def add_path(other, extend_path: false)
      mode = extend_path ? 1 : 0
      Native.sk_path_add_path(@ptr, other.ptr, mode, 0)
      self
    end

    def add_path_offset(other, dx, dy, extend_path: false)
      mode = extend_path ? 1 : 0
      Native.sk_path_add_path_offset(@ptr, other.ptr, dx.to_f, dy.to_f, mode)
      self
    end

    def add_path_matrix(other, matrix, extend_path: false)
      mode = extend_path ? 1 : 0
      matrix_struct = matrix.to_struct
      Native.sk_path_add_path_matrix(@ptr, other.ptr, matrix_struct, mode)
      self
    end

    def fill_type
      Native.sk_path_get_filltype(@ptr)
    end

    def fill_type=(value)
      Native.sk_path_set_filltype(@ptr, value)
    end

    def bounds
      rect_struct = Native::SKRect.new
      Native.sk_path_get_bounds(@ptr, rect_struct)
      Rect.from_struct(rect_struct)
    end

    def empty?
      Native.sk_path_count_verbs(@ptr) == 0
    end

    def contains?(x, y)
      Native.sk_path_contains(@ptr, x.to_f, y.to_f)
    end

    def transform(matrix)
      matrix_struct = matrix.to_struct
      Native.sk_path_transform(@ptr, matrix_struct)
      self
    end

    def clone
      self.class.new(Native.sk_path_clone(@ptr))
    end

    def reset
      Native.sk_path_reset(@ptr)
      self
    end
  end
end
