# frozen_string_literal: true

module Skia
  module Native
    # Surface
    attach_function :sk_surface_new_null, %i[int32 int32], :sk_surface_t
    attach_function :sk_surface_new_raster, [SKImageInfo.ptr, :size_t, :pointer], :sk_surface_t
    attach_function :sk_surface_new_raster_direct,
                    [SKImageInfo.ptr, :pointer, :size_t, :pointer, :pointer, :pointer], :sk_surface_t
    optional_attach_function :sk_surface_new_render_target,
                             [:gr_recording_context_t, :bool, SKImageInfo.ptr, :int, :gr_surface_origin_t,
                              :sk_surfaceprops_t, :bool], :sk_surface_t
    optional_attach_function :sk_surface_new_backend_render_target,
                             [:gr_recording_context_t, :gr_backendrendertarget_t, :gr_surface_origin_t,
                              :sk_colortype_t, :sk_colorspace_t, :sk_surfaceprops_t], :sk_surface_t
    optional_attach_function :sk_surface_new_backend_texture,
                             [:gr_recording_context_t, :gr_backendtexture_t, :gr_surface_origin_t, :int,
                              :sk_colortype_t, :sk_colorspace_t, :sk_surfaceprops_t], :sk_surface_t
    attach_function :sk_surface_unref, [:sk_surface_t], :void
    attach_function :sk_surface_get_canvas, [:sk_surface_t], :sk_canvas_t
    attach_function :sk_surface_new_image_snapshot, [:sk_surface_t], :sk_image_t
    attach_function :sk_surface_new_image_snapshot_with_crop, [:sk_surface_t, SKIRect.ptr], :sk_image_t
    attach_function :sk_surface_peek_pixels, %i[sk_surface_t sk_pixmap_t], :bool
    attach_function :sk_surface_read_pixels,
                    [:sk_surface_t, SKImageInfo.ptr, :pointer, :size_t, :int, :int], :bool
    attach_function :sk_surfaceprops_new, %i[uint32 sk_pixel_geometry_t], :sk_surfaceprops_t
    attach_function :sk_surfaceprops_delete, [:sk_surfaceprops_t], :void

    # Canvas - State
    attach_function :sk_canvas_save, [:sk_canvas_t], :int
    attach_function :sk_canvas_save_layer, [:sk_canvas_t, SKRect.ptr, :sk_paint_t], :int
    attach_function :sk_canvas_restore, [:sk_canvas_t], :void
    attach_function :sk_canvas_restore_to_count, %i[sk_canvas_t int], :void
    attach_function :sk_canvas_get_save_count, [:sk_canvas_t], :int

    # Canvas - Transform
    attach_function :sk_canvas_translate, %i[sk_canvas_t float float], :void
    attach_function :sk_canvas_scale, %i[sk_canvas_t float float], :void
    attach_function :sk_canvas_rotate_degrees, %i[sk_canvas_t float], :void
    attach_function :sk_canvas_rotate_radians, %i[sk_canvas_t float], :void
    attach_function :sk_canvas_skew, %i[sk_canvas_t float float], :void
    attach_function :sk_canvas_concat, [:sk_canvas_t, SKMatrix44.ptr], :void
    attach_function :sk_canvas_set_matrix, [:sk_canvas_t, SKMatrix44.ptr], :void
    attach_function :sk_canvas_get_matrix, [:sk_canvas_t, SKMatrix44.ptr], :void
    attach_function :sk_canvas_reset_matrix, [:sk_canvas_t], :void

    # Canvas - Clip
    attach_function :sk_canvas_clip_rect_with_operation,
                    [:sk_canvas_t, SKRect.ptr, :sk_clipop_t, :bool], :void
    attach_function :sk_canvas_clip_path_with_operation,
                    %i[sk_canvas_t sk_path_t sk_clipop_t bool], :void
    attach_function :sk_canvas_clip_rrect_with_operation,
                    %i[sk_canvas_t sk_rrect_t sk_clipop_t bool], :void
    attach_function :sk_canvas_clip_region, %i[sk_canvas_t pointer sk_clipop_t], :void

    # Canvas - Draw
    attach_function :sk_canvas_draw_paint, %i[sk_canvas_t sk_paint_t], :void
    attach_function :sk_canvas_draw_arc, [:sk_canvas_t, SKRect.ptr, :float, :float, :bool, :sk_paint_t], :void
    attach_function :sk_canvas_draw_rect, [:sk_canvas_t, SKRect.ptr, :sk_paint_t], :void
    attach_function :sk_canvas_draw_rrect, %i[sk_canvas_t sk_rrect_t sk_paint_t], :void
    attach_function :sk_canvas_draw_round_rect,
                    [:sk_canvas_t, SKRect.ptr, :float, :float, :sk_paint_t], :void
    attach_function :sk_canvas_draw_circle, %i[sk_canvas_t float float float sk_paint_t], :void
    attach_function :sk_canvas_draw_oval, [:sk_canvas_t, SKRect.ptr, :sk_paint_t], :void
    attach_function :sk_canvas_draw_path, %i[sk_canvas_t sk_path_t sk_paint_t], :void
    attach_function :sk_canvas_draw_picture, [:sk_canvas_t, :sk_picture_t, SKMatrix.ptr, :sk_paint_t], :void
    attach_function :sk_canvas_draw_image, %i[sk_canvas_t sk_image_t float float sk_paint_t], :void
    attach_function :sk_canvas_draw_image_rect,
                    [:sk_canvas_t, :sk_image_t, SKRect.ptr, SKRect.ptr, :sk_paint_t], :void
    attach_function :sk_canvas_draw_line, %i[sk_canvas_t float float float float sk_paint_t], :void
    attach_function :sk_canvas_draw_point, %i[sk_canvas_t float float sk_paint_t], :void
    attach_function :sk_canvas_draw_points, [:sk_canvas_t, :sk_point_mode_t, :size_t, :pointer, :sk_paint_t], :void
    attach_function :sk_canvas_draw_simple_text,
                    %i[sk_canvas_t pointer size_t sk_text_encoding_t float float sk_font_t sk_paint_t], :void
    attach_function :sk_canvas_draw_text_blob, %i[sk_canvas_t sk_textblob_t float float sk_paint_t], :void
    attach_function :sk_canvas_clear, %i[sk_canvas_t sk_color_t], :void
    attach_function :sk_canvas_draw_color, %i[sk_canvas_t sk_color_t sk_blend_mode_t], :void

    # Paint
    attach_function :sk_paint_new, [], :sk_paint_t
    attach_function :sk_paint_clone, [:sk_paint_t], :sk_paint_t
    attach_function :sk_paint_delete, [:sk_paint_t], :void
    attach_function :sk_paint_reset, [:sk_paint_t], :void
    attach_function :sk_paint_is_antialias, [:sk_paint_t], :bool
    attach_function :sk_paint_set_antialias, %i[sk_paint_t bool], :void
    attach_function :sk_paint_get_color, [:sk_paint_t], :sk_color_t
    attach_function :sk_paint_set_color, %i[sk_paint_t sk_color_t], :void
    attach_function :sk_paint_get_style, [:sk_paint_t], :sk_paint_style_t
    attach_function :sk_paint_set_style, %i[sk_paint_t sk_paint_style_t], :void
    attach_function :sk_paint_get_stroke_width, [:sk_paint_t], :float
    attach_function :sk_paint_set_stroke_width, %i[sk_paint_t float], :void
    attach_function :sk_paint_get_stroke_miter, [:sk_paint_t], :float
    attach_function :sk_paint_set_stroke_miter, %i[sk_paint_t float], :void
    attach_function :sk_paint_get_stroke_cap, [:sk_paint_t], :sk_stroke_cap_t
    attach_function :sk_paint_set_stroke_cap, %i[sk_paint_t sk_stroke_cap_t], :void
    attach_function :sk_paint_get_stroke_join, [:sk_paint_t], :sk_stroke_join_t
    attach_function :sk_paint_set_stroke_join, %i[sk_paint_t sk_stroke_join_t], :void
    attach_function :sk_paint_get_blendmode, [:sk_paint_t], :sk_blend_mode_t
    attach_function :sk_paint_set_blendmode, %i[sk_paint_t sk_blend_mode_t], :void
    attach_function :sk_paint_get_shader, [:sk_paint_t], :sk_shader_t
    attach_function :sk_paint_set_shader, %i[sk_paint_t sk_shader_t], :void
    attach_function :sk_paint_get_maskfilter, [:sk_paint_t], :sk_mask_filter_t
    attach_function :sk_paint_set_maskfilter, %i[sk_paint_t sk_mask_filter_t], :void
    attach_function :sk_paint_get_colorfilter, [:sk_paint_t], :sk_color_filter_t
    attach_function :sk_paint_set_colorfilter, %i[sk_paint_t sk_color_filter_t], :void
    attach_function :sk_paint_get_imagefilter, [:sk_paint_t], :sk_image_filter_t
    attach_function :sk_paint_set_imagefilter, %i[sk_paint_t sk_image_filter_t], :void
    attach_function :sk_paint_get_path_effect, [:sk_paint_t], :sk_path_effect_t
    attach_function :sk_paint_set_path_effect, %i[sk_paint_t sk_path_effect_t], :void

    # Path
    attach_function :sk_path_new, [], :sk_path_t
    attach_function :sk_path_clone, [:sk_path_t], :sk_path_t
    attach_function :sk_path_delete, [:sk_path_t], :void
    attach_function :sk_path_reset, [:sk_path_t], :void
    attach_function :sk_path_move_to, %i[sk_path_t float float], :void
    attach_function :sk_path_line_to, %i[sk_path_t float float], :void
    attach_function :sk_path_quad_to, %i[sk_path_t float float float float], :void
    attach_function :sk_path_conic_to, %i[sk_path_t float float float float float], :void
    attach_function :sk_path_cubic_to, %i[sk_path_t float float float float float float], :void
    attach_function :sk_path_arc_to, %i[sk_path_t float float float float float], :void
    attach_function :sk_path_arc_to_with_oval, [:sk_path_t, SKRect.ptr, :float, :float, :bool], :void
    attach_function :sk_path_close, [:sk_path_t], :void
    attach_function :sk_path_add_rect, [:sk_path_t, SKRect.ptr, :sk_path_direction_t], :void
    attach_function :sk_path_add_rrect, %i[sk_path_t sk_rrect_t sk_path_direction_t], :void
    attach_function :sk_path_add_oval, [:sk_path_t, SKRect.ptr, :sk_path_direction_t], :void
    attach_function :sk_path_add_circle, %i[sk_path_t float float float sk_path_direction_t], :void
    attach_function :sk_path_add_arc, [:sk_path_t, SKRect.ptr, :float, :float], :void
    attach_function :sk_path_add_path, %i[sk_path_t sk_path_t int int], :void
    attach_function :sk_path_add_path_offset, %i[sk_path_t sk_path_t float float int], :void
    attach_function :sk_path_add_path_reverse, %i[sk_path_t sk_path_t], :void
    attach_function :sk_path_add_path_matrix, [:sk_path_t, :sk_path_t, SKMatrix.ptr, :int], :void
    attach_function :sk_path_get_filltype, [:sk_path_t], :sk_path_filltype_t
    attach_function :sk_path_set_filltype, %i[sk_path_t sk_path_filltype_t], :void
    attach_function :sk_path_get_bounds, [:sk_path_t, SKRect.ptr], :void
    attach_function :sk_path_contains, %i[sk_path_t float float], :bool
    attach_function :sk_path_transform, [:sk_path_t, SKMatrix.ptr], :void
    attach_function :sk_path_count_points, [:sk_path_t], :int
    attach_function :sk_path_count_verbs, [:sk_path_t], :int

    # PathMeasure
    attach_function :sk_pathmeasure_new_with_path, [:sk_path_t, :bool, :float], :sk_pathmeasure_t
    attach_function :sk_pathmeasure_get_length, [:sk_pathmeasure_t], :float
    attach_function :sk_pathmeasure_destroy, [:sk_pathmeasure_t], :void
  end
end
