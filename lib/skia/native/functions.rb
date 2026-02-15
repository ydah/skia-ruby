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

    # Image
    attach_function :sk_image_ref, [:sk_image_t], :void
    attach_function :sk_image_unref, [:sk_image_t], :void
    attach_function :sk_image_get_width, [:sk_image_t], :int32
    attach_function :sk_image_get_height, [:sk_image_t], :int32
    attach_function :sk_image_get_unique_id, [:sk_image_t], :uint32
    attach_function :sk_image_get_color_type, [:sk_image_t], :sk_colortype_t
    attach_function :sk_image_get_alpha_type, [:sk_image_t], :sk_alphatype_t
    attach_function :sk_image_get_colorspace, [:sk_image_t], :sk_colorspace_t
    attach_function :sk_image_new_from_encoded, [:sk_data_t], :sk_image_t
    attach_function :sk_image_new_from_bitmap, [:sk_bitmap_t], :sk_image_t
    attach_function :sk_image_new_raster, [SKImageInfo.ptr, :pointer, :size_t, :pointer, :pointer], :sk_image_t
    attach_function :sk_image_ref_encoded, [:sk_image_t], :sk_data_t
    attach_function :sk_image_make_shader,
                    [:sk_image_t, :sk_shader_tilemode_t, :sk_shader_tilemode_t, SKSamplingOptions.ptr, SKMatrix.ptr], :sk_shader_t
    attach_function :sk_image_make_subset_raster, [:sk_image_t, SKIRect.ptr], :sk_image_t
    attach_function :sk_image_read_pixels,
                    [:sk_image_t, SKImageInfo.ptr, :pointer, :size_t, :int, :int, :sk_image_caching_hint_t], :bool

    # Pixmap
    attach_function :sk_pixmap_new, [], :sk_pixmap_t
    attach_function :sk_pixmap_new_with_params, [SKImageInfo.ptr, :pointer, :size_t], :sk_pixmap_t
    attach_function :sk_pixmap_destructor, [:sk_pixmap_t], :void
    attach_function :sk_pixmap_reset, [:sk_pixmap_t], :void
    attach_function :sk_pixmap_reset_with_params, [:sk_pixmap_t, SKImageInfo.ptr, :pointer, :size_t], :void
    attach_function :sk_pixmap_get_info, [:sk_pixmap_t, SKImageInfo.ptr], :void
    attach_function :sk_pixmap_get_row_bytes, [:sk_pixmap_t], :size_t
    attach_function :sk_pixmap_get_colorspace, [:sk_pixmap_t], :sk_colorspace_t
    attach_function :sk_pixmap_set_colorspace, [:sk_pixmap_t, :sk_colorspace_t], :void
    attach_function :sk_pixmap_get_pixel_color, [:sk_pixmap_t, :int, :int], :sk_color_t
    attach_function :sk_pixmap_get_writable_addr, [:sk_pixmap_t], :pointer
    attach_function :sk_pixmap_get_writeable_addr_with_xy, [:sk_pixmap_t, :int, :int], :pointer
    attach_function :sk_pixmap_read_pixels,
                    [:sk_pixmap_t, SKImageInfo.ptr, :pointer, :size_t, :int, :int], :bool
    attach_function :sk_pixmap_extract_subset, [:sk_pixmap_t, :sk_pixmap_t, SKIRect.ptr], :bool
    attach_function :sk_pixmap_compute_is_opaque, [:sk_pixmap_t], :bool

    # Bitmap
    attach_function :sk_bitmap_new, [], :sk_bitmap_t
    attach_function :sk_bitmap_destructor, [:sk_bitmap_t], :void
    attach_function :sk_bitmap_reset, [:sk_bitmap_t], :void
    attach_function :sk_bitmap_is_null, [:sk_bitmap_t], :bool
    attach_function :sk_bitmap_is_immutable, [:sk_bitmap_t], :bool
    attach_function :sk_bitmap_set_immutable, [:sk_bitmap_t], :void
    attach_function :sk_bitmap_get_info, [:sk_bitmap_t, SKImageInfo.ptr], :void
    attach_function :sk_bitmap_get_row_bytes, [:sk_bitmap_t], :size_t
    attach_function :sk_bitmap_get_byte_count, [:sk_bitmap_t], :size_t
    attach_function :sk_bitmap_get_pixels, [:sk_bitmap_t, :pointer], :pointer
    attach_function :sk_bitmap_set_pixels, [:sk_bitmap_t, :pointer], :void
    attach_function :sk_bitmap_install_pixels, [:sk_bitmap_t, SKImageInfo.ptr, :pointer, :size_t, :pointer, :pointer], :bool
    attach_function :sk_bitmap_try_alloc_pixels, [:sk_bitmap_t, SKImageInfo.ptr, :size_t], :bool
    attach_function :sk_bitmap_try_alloc_pixels_with_flags, [:sk_bitmap_t, SKImageInfo.ptr, :uint32], :bool
    attach_function :sk_bitmap_peek_pixels, [:sk_bitmap_t, :sk_pixmap_t], :bool
    attach_function :sk_bitmap_get_pixel_color, [:sk_bitmap_t, :int, :int], :sk_color_t
    attach_function :sk_bitmap_erase, [:sk_bitmap_t, :sk_color_t], :void
    attach_function :sk_bitmap_erase_rect, [:sk_bitmap_t, :sk_color_t, SKIRect.ptr], :void
    attach_function :sk_bitmap_extract_subset, [:sk_bitmap_t, :sk_bitmap_t, SKIRect.ptr], :bool
    attach_function :sk_bitmap_make_shader,
                    [:sk_bitmap_t, :sk_shader_tilemode_t, :sk_shader_tilemode_t, SKSamplingOptions.ptr, SKMatrix.ptr], :sk_shader_t

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

    # ColorSpace
    attach_function :sk_colorspace_ref, [:sk_colorspace_t], :void
    attach_function :sk_colorspace_unref, [:sk_colorspace_t], :void
    attach_function :sk_colorspace_new_srgb, [], :sk_colorspace_t
    attach_function :sk_colorspace_new_srgb_linear, [], :sk_colorspace_t
    attach_function :sk_colorspace_is_srgb, [:sk_colorspace_t], :bool
    attach_function :sk_colorspace_gamma_is_linear, [:sk_colorspace_t], :bool
    attach_function :sk_colorspace_equals, [:sk_colorspace_t, :sk_colorspace_t], :bool

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
    attach_function :sk_font_get_xpos, [:sk_font_t, :pointer, :int, :pointer, :float], :void
    attach_function :sk_font_text_to_glyphs,
                    [:sk_font_t, :pointer, :size_t, :sk_text_encoding_t, :pointer, :int], :int
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
    optional_attach_function :sk_shader_new_two_point_conical_gradient,
                             [SKPoint.ptr, :float, SKPoint.ptr, :float, :pointer, :pointer, :int,
                              :sk_shader_tilemode_t, SKMatrix.ptr], :sk_shader_t

    # MaskFilter
    attach_function :sk_maskfilter_new_blur, %i[sk_blur_style_t float], :sk_mask_filter_t
    attach_function :sk_maskfilter_new_blur_with_flags, %i[sk_blur_style_t float bool], :sk_mask_filter_t
    attach_function :sk_maskfilter_unref, [:sk_mask_filter_t], :void

    # ColorFilter
    attach_function :sk_colorfilter_new_mode, %i[sk_color_t sk_blend_mode_t], :sk_color_filter_t
    attach_function :sk_colorfilter_unref, [:sk_color_filter_t], :void

    # ImageFilter
    attach_function :sk_imagefilter_new_blur,
                    [:float, :float, :sk_shader_tilemode_t, :sk_image_filter_t, SKRect.ptr], :sk_image_filter_t
    attach_function :sk_imagefilter_unref, [:sk_image_filter_t], :void

    # PathEffect
    attach_function :sk_path_effect_create_dash, [:pointer, :int, :float], :sk_path_effect_t
    attach_function :sk_path_effect_unref, [:sk_path_effect_t], :void

    # Color
    attach_function :sk_colortype_get_default_8888, [], :sk_colortype_t

    # String
    attach_function :sk_string_destructor, [:sk_string_t], :void
    attach_function :sk_string_get_c_str, [:sk_string_t], :pointer
    attach_function :sk_string_get_size, [:sk_string_t], :size_t
    attach_function :sk_string_new_empty, [], :sk_string_t
    attach_function :sk_string_new_with_copy, [:pointer, :size_t], :sk_string_t

    # RRect
    attach_function :sk_rrect_new, [], :sk_rrect_t
    attach_function :sk_rrect_new_copy, [:sk_rrect_t], :sk_rrect_t
    attach_function :sk_rrect_delete, [:sk_rrect_t], :void
    attach_function :sk_rrect_set_empty, [:sk_rrect_t], :void
    attach_function :sk_rrect_set_rect, [:sk_rrect_t, SKRect.ptr], :void
    attach_function :sk_rrect_set_rect_xy, [:sk_rrect_t, SKRect.ptr, :float, :float], :void
    attach_function :sk_rrect_set_rect_radii, [:sk_rrect_t, SKRect.ptr, :pointer], :void
    attach_function :sk_rrect_get_rect, [:sk_rrect_t, SKRect.ptr], :void
    attach_function :sk_rrect_get_radii, [:sk_rrect_t, :sk_rrect_corner_t, SKPoint.ptr], :void
    attach_function :sk_rrect_get_type, [:sk_rrect_t], :sk_rrect_type_t
    attach_function :sk_rrect_get_width, [:sk_rrect_t], :float
    attach_function :sk_rrect_get_height, [:sk_rrect_t], :float
    attach_function :sk_rrect_is_valid, [:sk_rrect_t], :bool
    attach_function :sk_rrect_contains, [:sk_rrect_t, SKRect.ptr], :bool
    attach_function :sk_rrect_inset, [:sk_rrect_t, :float, :float], :void
    attach_function :sk_rrect_outset, [:sk_rrect_t, :float, :float], :void
    attach_function :sk_rrect_offset, [:sk_rrect_t, :float, :float], :void

    # Document (PDF)
    attach_function :sk_document_unref, [:sk_document_t], :void
    attach_function :sk_document_create_pdf_from_stream, [:pointer], :sk_document_t
    optional_attach_function :sk_document_create_pdf_from_stream_with_metadata,
                             [:pointer, SKDocumentPdfMetadata.ptr], :sk_document_t
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

    # TextBlob
    attach_function :sk_textblob_builder_new, [], :sk_textblob_builder_t
    attach_function :sk_textblob_builder_alloc_run_pos_h,
                    [:sk_textblob_builder_t, :sk_font_t, :int, :float, SKRect.ptr, SKRunBuffer.ptr], :void
    attach_function :sk_textblob_builder_make, [:sk_textblob_builder_t], :sk_textblob_t
    attach_function :sk_textblob_builder_delete, [:sk_textblob_builder_t], :void
    attach_function :sk_textblob_get_bounds, [:sk_textblob_t, SKRect.ptr], :void
    attach_function :sk_textblob_get_unique_id, [:sk_textblob_t], :uint32
    attach_function :sk_textblob_ref, [:sk_textblob_t], :void
    attach_function :sk_textblob_unref, [:sk_textblob_t], :void

    # Typeface extras
    attach_function :sk_typeface_get_family_name, [:sk_typeface_t], :sk_string_t
    optional_attach_function :sk_typeface_get_post_script_name, [:sk_typeface_t], :sk_string_t
    attach_function :sk_typeface_get_font_weight, [:sk_typeface_t], :int
    attach_function :sk_typeface_get_font_width, [:sk_typeface_t], :int
    attach_function :sk_typeface_get_font_slant, [:sk_typeface_t], :sk_font_style_slant_t
    attach_function :sk_typeface_is_fixed_pitch, [:sk_typeface_t], :bool
    attach_function :sk_typeface_get_units_per_em, [:sk_typeface_t], :int
    attach_function :sk_typeface_count_glyphs, [:sk_typeface_t], :int
    attach_function :sk_typeface_count_tables, [:sk_typeface_t], :int
    attach_function :sk_typeface_get_table_tags, [:sk_typeface_t, :pointer], :int
    attach_function :sk_typeface_get_table_size, [:sk_typeface_t, :uint32], :size_t
    attach_function :sk_typeface_get_table_data, [:sk_typeface_t, :uint32, :size_t, :size_t, :pointer], :size_t
    attach_function :sk_typeface_copy_table_data, [:sk_typeface_t, :uint32], :sk_data_t

    # RuntimeEffect
    optional_attach_function :sk_runtimeeffect_make_for_shader, [:sk_string_t, :sk_string_t], :sk_runtimeeffect_t
    optional_attach_function :sk_runtimeeffect_make_shader,
                             [:sk_runtimeeffect_t, :sk_data_t, :pointer, :size_t, SKMatrix.ptr], :sk_shader_t
    optional_attach_function :sk_runtimeeffect_unref, [:sk_runtimeeffect_t], :void
  end
end
