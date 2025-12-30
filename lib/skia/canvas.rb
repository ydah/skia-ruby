# frozen_string_literal: true

module Skia
  class Canvas < Base
    def initialize(ptr)
      super(ptr, nil)
    end

    def save
      Native.sk_canvas_save(@ptr)
    end

    def save_layer(bounds = nil, paint = nil)
      bounds_ptr = bounds&.to_struct
      paint_ptr = paint&.ptr
      Native.sk_canvas_save_layer(@ptr, bounds_ptr, paint_ptr)
    end

    def restore
      Native.sk_canvas_restore(@ptr)
    end

    def restore_to_count(count)
      Native.sk_canvas_restore_to_count(@ptr, count)
    end

    def save_count
      Native.sk_canvas_get_save_count(@ptr)
    end

    def translate(dx, dy)
      Native.sk_canvas_translate(@ptr, dx.to_f, dy.to_f)
      self
    end

    def scale(sx, sy = sx)
      Native.sk_canvas_scale(@ptr, sx.to_f, sy.to_f)
      self
    end

    def rotate(degrees, px = nil, py = nil)
      if px && py
        translate(px, py)
        Native.sk_canvas_rotate_degrees(@ptr, degrees.to_f)
        translate(-px, -py)
      else
        Native.sk_canvas_rotate_degrees(@ptr, degrees.to_f)
      end
      self
    end

    def rotate_radians(radians)
      Native.sk_canvas_rotate_radians(@ptr, radians.to_f)
      self
    end

    def skew(sx, sy)
      Native.sk_canvas_skew(@ptr, sx.to_f, sy.to_f)
      self
    end

    def concat(matrix)
      matrix_struct = matrix.to_struct44
      Native.sk_canvas_concat(@ptr, matrix_struct)
      self
    end

    def matrix=(matrix)
      matrix_struct = matrix.to_struct44
      Native.sk_canvas_set_matrix(@ptr, matrix_struct)
    end

    def matrix
      m = Native::SKMatrix44.new
      Native.sk_canvas_get_matrix(@ptr, m)
      Matrix.from_struct44(m)
    end

    def clip_rect(rect, op = :intersect, antialias: false)
      rect_struct = rect.to_struct
      Native.sk_canvas_clip_rect_with_operation(@ptr, rect_struct, op, antialias)
      self
    end

    def clip_path(path, op = :intersect, antialias: false)
      Native.sk_canvas_clip_path_with_operation(@ptr, path.ptr, op, antialias)
      self
    end

    def clear(color = Color::TRANSPARENT)
      color_value = color.is_a?(Color) ? color.to_i : color
      Native.sk_canvas_clear(@ptr, color_value)
      self
    end

    def draw_color(color, blend_mode = :src_over)
      color_value = color.is_a?(Color) ? color.to_i : color
      Native.sk_canvas_draw_color(@ptr, color_value, blend_mode)
      self
    end

    def draw_paint(paint)
      Native.sk_canvas_draw_paint(@ptr, paint.ptr)
      self
    end

    def draw_rect(rect, paint)
      rect_struct = rect.to_struct
      Native.sk_canvas_draw_rect(@ptr, rect_struct, paint.ptr)
      self
    end

    def draw_round_rect(rect, radius, paint)
      rect_struct = rect.to_struct
      Native.sk_canvas_draw_round_rect(@ptr, rect_struct, radius.to_f, radius.to_f, paint.ptr)
      self
    end

    def draw_circle(cx, cy, radius, paint)
      Native.sk_canvas_draw_circle(@ptr, cx.to_f, cy.to_f, radius.to_f, paint.ptr)
      self
    end

    def draw_oval(rect, paint)
      rect_struct = rect.to_struct
      Native.sk_canvas_draw_oval(@ptr, rect_struct, paint.ptr)
      self
    end

    def draw_path(path, paint)
      Native.sk_canvas_draw_path(@ptr, path.ptr, paint.ptr)
      self
    end

    def draw_line(x1, y1, x2, y2, paint)
      Native.sk_canvas_draw_line(@ptr, x1.to_f, y1.to_f, x2.to_f, y2.to_f, paint.ptr)
      self
    end

    def draw_image(image, x, y, paint = nil)
      Native.sk_canvas_draw_image(@ptr, image.ptr, x.to_f, y.to_f, paint&.ptr)
      self
    end

    def draw_image_rect(image, src_rect, dst_rect, paint = nil)
      src_struct = src_rect&.to_struct
      dst_struct = dst_rect.to_struct
      Native.sk_canvas_draw_image_rect(@ptr, image.ptr, src_struct, dst_struct, paint&.ptr)
      self
    end

    def draw_text(text, x, y, font, paint)
      text_bytes = text.encode('UTF-8')
      Native.sk_canvas_draw_simple_text(@ptr, text_bytes, text_bytes.bytesize, :utf8, x.to_f, y.to_f, font.ptr,
                                        paint.ptr)
      self
    end

    def with_save
      count = save
      begin
        yield self
      ensure
        restore_to_count(count)
      end
    end

    def with_save_layer(bounds = nil, paint = nil)
      count = save_layer(bounds, paint)
      begin
        yield self
      ensure
        restore_to_count(count)
      end
    end
  end
end
