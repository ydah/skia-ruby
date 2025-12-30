# frozen_string_literal: true

module Skia
  module Native
    # Surface
    attach_function :sk_surface_new_raster, [SKImageInfo.ptr, :size_t, :pointer], :sk_surface_t
    attach_function :sk_surface_new_raster_direct,
                    [SKImageInfo.ptr, :pointer, :size_t, :pointer, :pointer, :pointer], :sk_surface_t
    attach_function :sk_surface_unref, [:sk_surface_t], :void
    attach_function :sk_surface_get_canvas, [:sk_surface_t], :sk_canvas_t
    attach_function :sk_surface_new_image_snapshot, [:sk_surface_t], :sk_image_t
    attach_function :sk_surface_peek_pixels, %i[sk_surface_t sk_pixmap_t], :bool

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
    attach_function :sk_canvas_clip_region, %i[sk_canvas_t pointer sk_clipop_t], :void

    # Canvas - Draw
    attach_function :sk_canvas_draw_paint, %i[sk_canvas_t sk_paint_t], :void
    attach_function :sk_canvas_draw_rect, [:sk_canvas_t, SKRect.ptr, :sk_paint_t], :void
    attach_function :sk_canvas_draw_rrect, %i[sk_canvas_t pointer sk_paint_t], :void
    attach_function :sk_canvas_draw_round_rect,
                    [:sk_canvas_t, SKRect.ptr, :float, :float, :sk_paint_t], :void
    attach_function :sk_canvas_draw_circle, %i[sk_canvas_t float float float sk_paint_t], :void
    attach_function :sk_canvas_draw_oval, [:sk_canvas_t, SKRect.ptr, :sk_paint_t], :void
    attach_function :sk_canvas_draw_path, %i[sk_canvas_t sk_path_t sk_paint_t], :void
    attach_function :sk_canvas_draw_image, %i[sk_canvas_t sk_image_t float float sk_paint_t], :void
    attach_function :sk_canvas_draw_image_rect,
                    [:sk_canvas_t, :sk_image_t, SKRect.ptr, SKRect.ptr, :sk_paint_t], :void
    attach_function :sk_canvas_draw_line, %i[sk_canvas_t float float float float sk_paint_t], :void
    attach_function :sk_canvas_draw_point, %i[sk_canvas_t float float sk_paint_t], :void
    attach_function :sk_canvas_draw_points, %i[sk_canvas_t int size_t pointer sk_paint_t], :void
    attach_function :sk_canvas_draw_simple_text,
                    %i[sk_canvas_t pointer size_t sk_text_encoding_t float float sk_font_t sk_paint_t], :void
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
    attach_function :sk_path_add_rrect, %i[sk_path_t pointer sk_path_direction_t], :void
    attach_function :sk_path_add_oval, [:sk_path_t, SKRect.ptr, :sk_path_direction_t], :void
    attach_function :sk_path_add_circle, %i[sk_path_t float float float sk_path_direction_t], :void
    attach_function :sk_path_add_arc, [:sk_path_t, SKRect.ptr, :float, :float], :void
    attach_function :sk_path_add_path, %i[sk_path_t sk_path_t int int], :void
    attach_function :sk_path_add_path_offset, %i[sk_path_t sk_path_t float float int], :void
    attach_function :sk_path_add_path_matrix, [:sk_path_t, :sk_path_t, SKMatrix.ptr, :int], :void
    attach_function :sk_path_get_filltype, [:sk_path_t], :sk_path_filltype_t
    attach_function :sk_path_set_filltype, %i[sk_path_t sk_path_filltype_t], :void
    attach_function :sk_path_get_bounds, [:sk_path_t, SKRect.ptr], :void
    attach_function :sk_path_contains, %i[sk_path_t float float], :bool
    attach_function :sk_path_transform, [:sk_path_t, SKMatrix.ptr], :void
    attach_function :sk_path_count_points, [:sk_path_t], :int
    attach_function :sk_path_count_verbs, [:sk_path_t], :int

    # Image
    attach_function :sk_image_ref, [:sk_image_t], :void
    attach_function :sk_image_unref, [:sk_image_t], :void
    attach_function :sk_image_get_width, [:sk_image_t], :int32
    attach_function :sk_image_get_height, [:sk_image_t], :int32
    attach_function :sk_image_get_unique_id, [:sk_image_t], :uint32
    attach_function :sk_image_new_from_encoded, [:sk_data_t], :sk_image_t
    attach_function :sk_image_ref_encoded, [:sk_image_t], :sk_data_t

    # Pixmap
    attach_function :sk_pixmap_new, [], :sk_pixmap_t
    attach_function :sk_pixmap_destructor, [:sk_pixmap_t], :void
    attach_function :sk_pixmap_get_info, [:sk_pixmap_t, SKImageInfo.ptr], :void

    # Image - Pixmap operations
    attach_function :sk_image_peek_pixels, %i[sk_image_t sk_pixmap_t], :bool

    # Encoders (take sk_pixmap_t, not sk_image_t)
    attach_function :sk_pngencoder_encode, [:pointer, :sk_pixmap_t, SKPngEncoderOptions.ptr], :bool
    attach_function :sk_jpegencoder_encode, [:pointer, :sk_pixmap_t, SKJpegEncoderOptions.ptr], :bool
    attach_function :sk_webpencoder_encode, [:pointer, :sk_pixmap_t, SKWebpEncoderOptions.ptr], :bool

    # Data
    attach_function :sk_data_new_with_copy, %i[pointer size_t], :sk_data_t
    attach_function :sk_data_new_from_file, [:string], :sk_data_t
    attach_function :sk_data_ref, [:sk_data_t], :void
    attach_function :sk_data_unref, [:sk_data_t], :void
    attach_function :sk_data_get_size, [:sk_data_t], :size_t
    attach_function :sk_data_get_data, [:sk_data_t], :pointer

    # Stream
    attach_function :sk_dynamicmemorywstream_new, [], :pointer
    attach_function :sk_dynamicmemorywstream_destroy, [:pointer], :void
    attach_function :sk_dynamicmemorywstream_detach_as_data, [:pointer], :sk_data_t

    # Typeface
    attach_function :sk_typeface_create_from_name, %i[string pointer], :sk_typeface_t
    attach_function :sk_typeface_create_from_file, %i[string int], :sk_typeface_t
    attach_function :sk_typeface_create_default, [], :sk_typeface_t
    attach_function :sk_typeface_unref, [:sk_typeface_t], :void

    # FontStyle
    attach_function :sk_fontstyle_new, %i[int int sk_font_style_slant_t], :pointer
    attach_function :sk_fontstyle_delete, [:pointer], :void

    # Font
    attach_function :sk_font_new, [], :sk_font_t
    attach_function :sk_font_new_with_values, %i[sk_typeface_t float float float], :sk_font_t
    attach_function :sk_font_delete, [:sk_font_t], :void
    attach_function :sk_font_set_typeface, %i[sk_font_t sk_typeface_t], :void
    attach_function :sk_font_get_typeface, [:sk_font_t], :sk_typeface_t
    attach_function :sk_font_set_size, %i[sk_font_t float], :void
    attach_function :sk_font_get_size, [:sk_font_t], :float
    attach_function :sk_font_get_metrics, [:sk_font_t, SKFontMetrics.ptr], :float
    attach_function :sk_font_measure_text,
                    [:sk_font_t, :pointer, :size_t, :sk_text_encoding_t, SKRect.ptr, :sk_paint_t], :float

    # Shader
    attach_function :sk_shader_unref, [:sk_shader_t], :void
    attach_function :sk_shader_new_linear_gradient,
                    [:pointer, :pointer, :pointer, :int, :sk_shader_tilemode_t, SKMatrix.ptr], :sk_shader_t
    attach_function :sk_shader_new_radial_gradient,
                    [SKPoint.ptr, :float, :pointer, :pointer, :int, :sk_shader_tilemode_t, SKMatrix.ptr], :sk_shader_t
    attach_function :sk_shader_new_sweep_gradient,
                    [SKPoint.ptr, :pointer, :pointer, :int, :sk_shader_tilemode_t, :float, :float, SKMatrix.ptr], :sk_shader_t

    # MaskFilter
    attach_function :sk_maskfilter_new_blur, %i[int float], :sk_mask_filter_t
    attach_function :sk_maskfilter_unref, [:sk_mask_filter_t], :void

    # Color
    attach_function :sk_colortype_get_default_8888, [], :sk_colortype_t

    # Document (PDF)
    attach_function :sk_document_unref, [:sk_document_t], :void
    attach_function :sk_document_create_pdf_from_stream, [:pointer], :sk_document_t
    attach_function :sk_document_begin_page, [:sk_document_t, :float, :float, SKRect.ptr], :sk_canvas_t
    attach_function :sk_document_end_page, [:sk_document_t], :void
    attach_function :sk_document_close, [:sk_document_t], :void
    attach_function :sk_document_abort, [:sk_document_t], :void

    # FileWStream (for PDF output)
    attach_function :sk_filewstream_new, [:string], :pointer
    attach_function :sk_filewstream_destroy, [:pointer], :void

    # Picture Recorder
    attach_function :sk_picture_recorder_new, [], :sk_picture_recorder_t
    attach_function :sk_picture_recorder_delete, [:sk_picture_recorder_t], :void
    attach_function :sk_picture_recorder_begin_recording, [:sk_picture_recorder_t, SKRect.ptr], :sk_canvas_t
    attach_function :sk_picture_recorder_end_recording, [:sk_picture_recorder_t], :sk_picture_t
    attach_function :sk_picture_get_recording_canvas, [:sk_picture_recorder_t], :sk_canvas_t

    # Picture
    attach_function :sk_picture_ref, [:sk_picture_t], :void
    attach_function :sk_picture_unref, [:sk_picture_t], :void
    attach_function :sk_picture_get_unique_id, [:sk_picture_t], :uint32
    attach_function :sk_picture_get_cull_rect, [:sk_picture_t, SKRect.ptr], :void
    attach_function :sk_picture_playback, %i[sk_picture_t sk_canvas_t], :void
    attach_function :sk_picture_serialize_to_data, [:sk_picture_t], :sk_data_t
    attach_function :sk_picture_deserialize_from_data, [:sk_data_t], :sk_picture_t
    attach_function :sk_picture_approximate_op_count, %i[sk_picture_t bool], :int
    attach_function :sk_picture_approximate_bytes_used, [:sk_picture_t], :size_t
  end
end
