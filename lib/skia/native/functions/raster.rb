# frozen_string_literal: true

module Skia
  module Native
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
    attach_function :sk_pixmap_set_colorspace, %i[sk_pixmap_t sk_colorspace_t], :void
    attach_function :sk_pixmap_get_pixel_color, %i[sk_pixmap_t int int], :sk_color_t
    attach_function :sk_pixmap_get_writable_addr, [:sk_pixmap_t], :pointer
    attach_function :sk_pixmap_get_writeable_addr_with_xy, %i[sk_pixmap_t int int], :pointer
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
    attach_function :sk_bitmap_get_pixels, %i[sk_bitmap_t pointer], :pointer
    attach_function :sk_bitmap_set_pixels, %i[sk_bitmap_t pointer], :void
    attach_function :sk_bitmap_install_pixels, [:sk_bitmap_t, SKImageInfo.ptr, :pointer, :size_t, :pointer, :pointer], :bool
    attach_function :sk_bitmap_try_alloc_pixels, [:sk_bitmap_t, SKImageInfo.ptr, :size_t], :bool
    attach_function :sk_bitmap_try_alloc_pixels_with_flags, [:sk_bitmap_t, SKImageInfo.ptr, :uint32], :bool
    attach_function :sk_bitmap_peek_pixels, %i[sk_bitmap_t sk_pixmap_t], :bool
    attach_function :sk_bitmap_get_pixel_color, %i[sk_bitmap_t int int], :sk_color_t
    attach_function :sk_bitmap_erase, %i[sk_bitmap_t sk_color_t], :void
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

    # Codec
    attach_function :sk_codec_new_from_data, [:sk_data_t], :sk_codec_t
    attach_function :sk_codec_destroy, [:sk_codec_t], :void
    attach_function :sk_codec_get_info, [:sk_codec_t, SKImageInfo.ptr], :void
    attach_function :sk_codec_get_origin, [:sk_codec_t], :sk_encodedorigin_t
    attach_function :sk_codec_get_encoded_format, [:sk_codec_t], :sk_encoded_image_format_t
    attach_function :sk_codec_get_frame_count, [:sk_codec_t], :int
    attach_function :sk_codec_get_repetition_count, [:sk_codec_t], :int
    attach_function :sk_codec_get_frame_info_for_index, [:sk_codec_t, :int, SKCodecFrameInfo.ptr], :bool
    attach_function :sk_codec_get_pixels,
                    [:sk_codec_t, SKImageInfo.ptr, :pointer, :size_t, SKCodecOptions.ptr], :sk_codec_result_t

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
    attach_function :sk_colorspace_equals, %i[sk_colorspace_t sk_colorspace_t], :bool
  end
end
