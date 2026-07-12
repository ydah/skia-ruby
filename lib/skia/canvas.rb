# frozen_string_literal: true

module Skia
  class Canvas < Base
    def initialize(ptr, owner: nil, release_method: nil)
      super(ptr, release_method, owner: owner)
    end

    def save
      Native.sk_canvas_save(ptr)
    end

    def save_layer(bounds = nil, paint = nil)
      bounds_ptr = bounds&.to_struct
      paint_ptr = paint&.ptr
      Native.sk_canvas_save_layer(ptr, bounds_ptr, paint_ptr)
    end

    def restore
      Native.sk_canvas_restore(ptr)
    end

    def restore_to_count(count)
      Native.sk_canvas_restore_to_count(ptr, count)
    end

    def save_count
      Native.sk_canvas_get_save_count(ptr)
    end

    def translate(dx, dy)
      Native.sk_canvas_translate(ptr, dx.to_f, dy.to_f)
      self
    end

    def scale(sx, sy = sx)
      Native.sk_canvas_scale(ptr, sx.to_f, sy.to_f)
      self
    end

    def rotate(degrees, px = nil, py = nil)
      if px && py
        translate(px, py)
        Native.sk_canvas_rotate_degrees(ptr, degrees.to_f)
        translate(-px, -py)
      else
        Native.sk_canvas_rotate_degrees(ptr, degrees.to_f)
      end
      self
    end

    def rotate_radians(radians)
      Native.sk_canvas_rotate_radians(ptr, radians.to_f)
      self
    end

    def skew(sx, sy)
      Native.sk_canvas_skew(ptr, sx.to_f, sy.to_f)
      self
    end

    def concat(matrix)
      matrix_struct = matrix.to_struct44
      Native.sk_canvas_concat(ptr, matrix_struct)
      self
    end

    def matrix=(matrix)
      matrix_struct = matrix.to_struct44
      Native.sk_canvas_set_matrix(ptr, matrix_struct)
    end

    def matrix
      m = Native::SKMatrix44.new
      Native.sk_canvas_get_matrix(ptr, m)
      Matrix.from_struct44(m)
    end

    def reset_matrix
      Native.sk_canvas_reset_matrix(ptr)
      self
    end

    def clip_rect(rect, op = :intersect, antialias: false)
      rect_struct = rect.to_struct
      Native.sk_canvas_clip_rect_with_operation(ptr, rect_struct, op, antialias)
      self
    end

    def clip_path(path, op = :intersect, antialias: false)
      Native.sk_canvas_clip_path_with_operation(ptr, path.ptr, op, antialias)
      self
    end

    def clip_rrect(rrect, op = :intersect, antialias: false)
      Native.sk_canvas_clip_rrect_with_operation(ptr, rrect.ptr, op, antialias)
      self
    end

    def clip_region(region, op = :intersect)
      raise ArgumentError, 'region must be a Skia::Region' unless region.is_a?(Region)

      Native.sk_canvas_clip_region(ptr, region.ptr, op)
      self
    end

    def quick_reject?(rect)
      raise ArgumentError, 'rect must be a Skia::Rect' unless rect.is_a?(Rect)

      Native.sk_canvas_quick_reject(ptr, rect.to_struct)
    end

    def clear(color = Color::TRANSPARENT)
      color_value = color.is_a?(Color) ? color.to_i : color
      Native.sk_canvas_clear(ptr, color_value)
      self
    end

    def draw_color(color, blend_mode = :src_over)
      color_value = color.is_a?(Color) ? color.to_i : color
      Native.sk_canvas_draw_color(ptr, color_value, blend_mode)
      self
    end

    def draw_paint(paint)
      Native.sk_canvas_draw_paint(ptr, paint.ptr)
      self
    end

    def draw_rect(rect, paint)
      rect_struct = rect.to_struct
      Native.sk_canvas_draw_rect(ptr, rect_struct, paint.ptr)
      self
    end

    def draw_rrect(rrect, paint)
      Native.sk_canvas_draw_rrect(ptr, rrect.ptr, paint.ptr)
      self
    end

    def draw_round_rect(rect, radius, paint)
      rect_struct = rect.to_struct
      Native.sk_canvas_draw_round_rect(ptr, rect_struct, radius.to_f, radius.to_f, paint.ptr)
      self
    end

    def draw_arc(oval, start_angle, sweep_angle, use_center, paint)
      oval_struct = oval.to_struct
      Native.sk_canvas_draw_arc(ptr, oval_struct, start_angle.to_f, sweep_angle.to_f, use_center, paint.ptr)
      self
    end

    def draw_circle(cx, cy, radius, paint)
      Native.sk_canvas_draw_circle(ptr, cx.to_f, cy.to_f, radius.to_f, paint.ptr)
      self
    end

    def draw_oval(rect, paint)
      rect_struct = rect.to_struct
      Native.sk_canvas_draw_oval(ptr, rect_struct, paint.ptr)
      self
    end

    def draw_path(path, paint)
      Native.sk_canvas_draw_path(ptr, path.ptr, paint.ptr)
      self
    end

    def draw_region(region, paint)
      raise ArgumentError, 'region must be a Skia::Region' unless region.is_a?(Region)

      Native.sk_canvas_draw_region(ptr, region.ptr, paint.ptr)
      self
    end

    def draw_picture(picture, matrix = nil, paint = nil)
      matrix_struct = matrix&.to_struct
      Native.sk_canvas_draw_picture(ptr, picture.ptr, matrix_struct, paint&.ptr)
      self
    end

    def draw_line(x1, y1, x2, y2, paint)
      Native.sk_canvas_draw_line(ptr, x1.to_f, y1.to_f, x2.to_f, y2.to_f, paint.ptr)
      self
    end

    def draw_point(x, y, paint)
      Native.sk_canvas_draw_point(ptr, x.to_f, y.to_f, paint.ptr)
      self
    end

    def draw_points(points, paint, mode: :points)
      return self if points.empty?

      point_structs = points.map { |point| coerce_point(point).to_struct }
      points_ptr = FFI::MemoryPointer.new(Native::SKPoint, point_structs.length)

      point_structs.each_with_index do |point_struct, index|
        destination = Native::SKPoint.new(points_ptr + (index * Native::SKPoint.size))
        destination[:x] = point_struct[:x]
        destination[:y] = point_struct[:y]
      end

      Native.sk_canvas_draw_points(ptr, mode, point_structs.length, points_ptr, paint.ptr)
      self
    end

    def draw_image(image, x, y, paint = nil, sampling: SamplingOptions.default)
      Native.sk_canvas_draw_image(ptr, image.ptr, x.to_f, y.to_f, sampling.to_struct, paint&.ptr)
      self
    end

    def draw_image_rect(image, src_rect, dst_rect, paint = nil, sampling: SamplingOptions.default)
      src_struct = src_rect&.to_struct
      dst_struct = dst_rect.to_struct
      Native.sk_canvas_draw_image_rect(ptr, image.ptr, src_struct, dst_struct, sampling.to_struct, paint&.ptr)
      self
    end

    def draw_vertices(vertices, paint, blend_mode: :modulate)
      raise ArgumentError, 'vertices must be Skia::Vertices' unless vertices.is_a?(Vertices)

      Native.sk_canvas_draw_vertices(ptr, vertices.ptr, blend_mode, paint.ptr)
      self
    end

    def draw_atlas(atlas, sprites:, transforms:, colors: nil, blend_mode: :dst, sampling: SamplingOptions.default,
                   cull_rect: nil, paint: nil)
      raise ArgumentError, 'atlas must be a Skia::Image' unless atlas.is_a?(Image)
      raise ArgumentError, 'sprites and transforms must have the same length' unless sprites.length == transforms.length
      raise ArgumentError, 'colors and sprites must have the same length' if colors && colors.length != sprites.length
      return self if sprites.empty?

      sprite_ptr = struct_array(Native::SKRect, sprites, &:to_struct)
      transform_ptr = struct_array(Native::SKRotationScaleMatrix, transforms, &:to_struct)
      color_ptr = color_array(colors)
      Native.sk_canvas_draw_atlas(
        ptr, atlas.ptr, transform_ptr, sprite_ptr, color_ptr, sprites.length, blend_mode,
        sampling.to_struct, cull_rect&.to_struct, paint&.ptr
      )
      self
    end

    def draw_patch(cubics, paint, colors: nil, texture_coords: nil, blend_mode: :modulate)
      raise ArgumentError, 'cubics must contain exactly 12 points' unless cubics.length == 12
      raise ArgumentError, 'colors must contain exactly 4 colors' if colors && colors.length != 4
      raise ArgumentError, 'texture_coords must contain exactly 4 points' if texture_coords && texture_coords.length != 4

      cubic_ptr = struct_array(Native::SKPoint, cubics) { |point| coerce_point(point).to_struct }
      texture_ptr = struct_array(Native::SKPoint, texture_coords) { |point| coerce_point(point).to_struct }
      Native.sk_canvas_draw_patch(ptr, cubic_ptr, color_array(colors), texture_ptr, blend_mode, paint.ptr)
      self
    end

    def draw_text(text, x, y, font, paint)
      text_bytes = text.encode('UTF-8')
      Native.sk_canvas_draw_simple_text(ptr, text_bytes, text_bytes.bytesize, :utf8, x.to_f, y.to_f, font.ptr,
                                        paint.ptr)
      self
    end

    def draw_text_blob(blob, x, y, paint)
      Native.sk_canvas_draw_text_blob(ptr, blob.ptr, x.to_f, y.to_f, paint.ptr)
      self
    end

    def draw_text_on_path(text, path, font, paint, offset: 0.0)
      blob = TextBlob.from_text_on_path(text, font, path, offset: offset)
      draw_text_blob(blob, 0, 0, paint) if blob
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

    private

    def coerce_point(point)
      return point if point.is_a?(Point)
      return Point.new(point[0], point[1]) if point.is_a?(Array) && point.length == 2

      raise ArgumentError, 'point must be Skia::Point or [x, y]'
    end

    def struct_array(struct_class, values)
      return nil if values.nil?

      pointer = FFI::MemoryPointer.new(struct_class, values.length)
      values.each_with_index do |value, index|
        destination = struct_class.new(pointer + (index * struct_class.size))
        destination.to_ptr.write_bytes(yield(value).to_ptr.read_bytes(struct_class.size))
      end
      pointer
    end

    def color_array(colors)
      return nil if colors.nil?

      values = colors.map { |color| color.is_a?(Color) ? color.to_i : color }
      pointer = FFI::MemoryPointer.new(:uint32, values.length)
      pointer.write_array_of_uint32(values)
      pointer
    end
  end
end
