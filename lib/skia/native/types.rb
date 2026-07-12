# frozen_string_literal: true

module Skia
  module Native
    typedef :uint32, :sk_color_t
    typedef :uint32, :sk_pmcolor_t
    typedef :pointer, :sk_surface_t
    typedef :pointer, :sk_canvas_t
    typedef :pointer, :sk_paint_t
    typedef :pointer, :sk_path_t
    typedef :pointer, :sk_image_t
    typedef :pointer, :sk_data_t
    typedef :pointer, :sk_shader_t
    typedef :pointer, :sk_typeface_t
    typedef :pointer, :sk_font_t
    typedef :pointer, :sk_mask_filter_t
    typedef :pointer, :sk_color_filter_t
    typedef :pointer, :sk_image_filter_t
    typedef :pointer, :sk_path_effect_t
    typedef :pointer, :sk_bitmap_t
    typedef :pointer, :sk_pixmap_t
    typedef :pointer, :sk_colorspace_t
    typedef :pointer, :sk_document_t
    typedef :pointer, :sk_picture_t
    typedef :pointer, :sk_picture_recorder_t
    typedef :pointer, :sk_pathmeasure_t
    typedef :pointer, :sk_region_t
    typedef :pointer, :sk_region_iterator_t
    typedef :pointer, :sk_vertices_t
    typedef :pointer, :sk_blender_t
    typedef :pointer, :sk_fontmgr_t
    typedef :pointer, :sk_surfaceprops_t
    typedef :pointer, :sk_rrect_t
    typedef :pointer, :sk_textblob_t
    typedef :pointer, :sk_textblob_builder_t
    typedef :pointer, :sk_runtimeeffect_t
    typedef :pointer, :sk_flattenable_t
    typedef :pointer, :sk_string_t
    typedef :pointer, :sk_drawable_t
    typedef :pointer, :gr_recording_context_t
    typedef :pointer, :gr_backendrendertarget_t
    typedef :pointer, :gr_backendtexture_t

    enum :sk_colortype_t, [
      :unknown,      0,
      :alpha_8,      1,
      :rgb_565,      2,
      :argb_4444,    3,
      :rgba_8888,    4,
      :rgb_888x,     5,
      :bgra_8888,    6,
      :rgba_1010102, 7,
      :rgb_101010x,  8,
      :gray_8,       9,
      :rgba_f16,    10,
      :rgba_f32,    11
    ]

    enum :sk_alphatype_t, [
      :unknown,   0,
      :opaque,    1,
      :premul,    2,
      :unpremul,  3
    ]

    enum :sk_paint_style_t, [
      :fill,           0,
      :stroke,         1,
      :stroke_and_fill, 2
    ]

    enum :sk_stroke_cap_t, [
      :butt,   0,
      :round,  1,
      :square, 2
    ]

    enum :sk_stroke_join_t, [
      :miter, 0,
      :round, 1,
      :bevel, 2
    ]

    enum :sk_blend_mode_t, [
      :clear,       0,
      :src,         1,
      :dst,         2,
      :src_over,    3,
      :dst_over,    4,
      :src_in,      5,
      :dst_in,      6,
      :src_out,     7,
      :dst_out,     8,
      :src_atop,    9,
      :dst_atop,   10,
      :xor,        11,
      :plus,       12,
      :modulate,   13,
      :screen,     14,
      :overlay,    15,
      :darken,     16,
      :lighten,    17,
      :color_dodge, 18,
      :color_burn, 19,
      :hard_light, 20,
      :soft_light, 21,
      :difference, 22,
      :exclusion,  23,
      :multiply,   24,
      :hue,        25,
      :saturation, 26,
      :color,      27,
      :luminosity, 28
    ]

    enum :sk_path_filltype_t, [
      :winding,          0,
      :even_odd,         1,
      :inverse_winding,  2,
      :inverse_even_odd, 3
    ]

    enum :sk_path_direction_t, [
      :cw,  0,
      :ccw, 1
    ]

    enum :sk_pathop_t, [
      :difference,         0,
      :intersect,          1,
      :union,              2,
      :xor,                3,
      :reverse_difference, 4
    ]

    enum :sk_pathmeasure_matrixflags_t, [
      :position,             1,
      :tangent,              2,
      :position_and_tangent, 3
    ]

    enum :sk_region_op_t, [
      :difference,         0,
      :intersect,          1,
      :union,              2,
      :xor,                3,
      :reverse_difference, 4,
      :replace,            5
    ]

    enum :sk_clipop_t, [
      :difference, 0,
      :intersect,  1
    ]

    enum :sk_blur_style_t, [
      :normal, 0,
      :solid,  1,
      :outer,  2,
      :inner,  3
    ]

    enum :sk_point_mode_t, [
      :points,  0,
      :lines,   1,
      :polygon, 2
    ]

    enum :sk_vertices_vertex_mode_t, [
      :triangles,      0,
      :triangle_strip, 1,
      :triangle_fan,   2
    ]

    enum :sk_image_caching_hint_t, [
      :allow,    0,
      :disallow, 1
    ]

    enum :sk_rrect_corner_t, [
      :upper_left,  0,
      :upper_right, 1,
      :lower_right, 2,
      :lower_left,  3
    ]

    enum :sk_rrect_type_t, [
      :empty,      0,
      :rect,       1,
      :oval,       2,
      :simple,     3,
      :nine_patch, 4,
      :complex,    5
    ]

    enum :sk_encoded_image_format_t, [
      :bmp,  0,
      :gif,  1,
      :ico,  2,
      :jpeg, 3,
      :png,  4,
      :wbmp, 5,
      :webp, 6,
      :pkm,  7,
      :ktx,  8,
      :astc, 9,
      :dng, 10,
      :heif, 11
    ]

    enum :sk_shader_tilemode_t, [
      :clamp,  0,
      :repeat, 1,
      :mirror, 2,
      :decal,  3
    ]

    enum :sk_filter_mode_t, [
      :nearest, 0,
      :linear,  1
    ]

    enum :sk_mipmap_mode_t, [
      :none,    0,
      :nearest, 1,
      :linear,  2
    ]

    enum :sk_font_style_slant_t, [
      :upright, 0,
      :italic,  1,
      :oblique, 2
    ]

    enum :sk_text_encoding_t, [
      :utf8,     0,
      :utf16,    1,
      :utf32,    2,
      :glyph_id, 3
    ]

    enum :gr_surface_origin_t, [
      :top_left,    0,
      :bottom_left, 1
    ]

    enum :sk_pixel_geometry_t, [
      :unknown, 0,
      :rgb_h,   1,
      :bgr_h,   2,
      :rgb_v,   3,
      :bgr_v,   4
    ]

    class SKPoint < FFI::Struct
      layout :x, :float,
             :y, :float
    end

    class SKIPoint < FFI::Struct
      layout :x, :int32,
             :y, :int32
    end

    class SKRect < FFI::Struct
      layout :left,   :float,
             :top,    :float,
             :right,  :float,
             :bottom, :float
    end

    class SKIRect < FFI::Struct
      layout :left,   :int32,
             :top,    :int32,
             :right,  :int32,
             :bottom, :int32
    end

    class SKSize < FFI::Struct
      layout :width,  :float,
             :height, :float
    end

    class SKISize < FFI::Struct
      layout :width,  :int32,
             :height, :int32
    end

    class SKMatrix < FFI::Struct
      layout :scaleX,  :float,
             :skewX,   :float,
             :transX,  :float,
             :skewY,   :float,
             :scaleY,  :float,
             :transY,  :float,
             :persp0,  :float,
             :persp1,  :float,
             :persp2,  :float
    end

    # 4x4 matrix (row major order)
    class SKMatrix44 < FFI::Struct
      layout :m00, :float, :m01, :float, :m02, :float, :m03, :float,
             :m10, :float, :m11, :float, :m12, :float, :m13, :float,
             :m20, :float, :m21, :float, :m22, :float, :m23, :float,
             :m30, :float, :m31, :float, :m32, :float, :m33, :float
    end

    class SKImageInfo < FFI::Struct
      layout :colorspace, :pointer,
             :width,      :int32,
             :height,     :int32,
             :colorType,  :sk_colortype_t,
             :alphaType,  :sk_alphatype_t
    end

    class SKFontMetrics < FFI::Struct
      layout :flags,              :uint32,
             :top,                :float,
             :ascent,             :float,
             :descent,            :float,
             :bottom,             :float,
             :leading,            :float,
             :avgCharWidth,       :float,
             :maxCharWidth,       :float,
             :xMin,               :float,
             :xMax,               :float,
             :xHeight,            :float,
             :capHeight,          :float,
             :underlineThickness, :float,
             :underlinePosition,  :float,
             :strikeoutThickness, :float,
             :strikeoutPosition,  :float
    end

    # sk_sampling_options_t
    class SKSamplingOptions < FFI::Struct
      layout :fMaxAniso, :int32,
             :fUseCubic, :uint8,
             :_pad0,     [:uint8, 3],
             :fCubicB,   :float,
             :fCubicC,   :float,
             :fFilter,   :sk_filter_mode_t,
             :fMipmap,   :sk_mipmap_mode_t
    end

    class SKRotationScaleMatrix < FFI::Struct
      layout :scos, :float,
             :ssin, :float,
             :tx,   :float,
             :ty,   :float
    end

    # sk_textblob_builder_runbuffer_t
    class SKRunBuffer < FFI::Struct
      layout :glyphs,   :pointer,
             :pos,      :pointer,
             :utf8text, :pointer,
             :clusters, :pointer
    end

    class SKTimeDateTime < FFI::Struct
      layout :fTimeZoneMinutes, :int16,
             :fYear,            :uint16,
             :fMonth,           :uint8,
             :fDayOfWeek,       :uint8,
             :fDay,             :uint8,
             :fHour,            :uint8,
             :fMinute,          :uint8,
             :fSecond,          :uint8
    end

    class SKDocumentPdfMetadata < FFI::Struct
      layout :fTitle,           :sk_string_t,
             :fAuthor,          :sk_string_t,
             :fSubject,         :sk_string_t,
             :fKeywords,        :sk_string_t,
             :fCreator,         :sk_string_t,
             :fProducer,        :sk_string_t,
             :fCreation,        SKTimeDateTime.ptr,
             :fModified,        SKTimeDateTime.ptr,
             :fRasterDPI,       :float,
             :fPDFA,            :uint8,
             :_pad_pdfa,        [:uint8, 3],
             :fEncodingQuality, :int32
    end

    # PNG Encoder
    enum :sk_pngencoder_filterflags_t, [
      :zero,  0x00,
      :none,  0x08,
      :sub,   0x10,
      :up,    0x20,
      :avg,   0x40,
      :paeth, 0x80,
      :all,   0xF8
    ]

    class SKPngEncoderOptions < FFI::Struct
      layout :fFilterFlags, :sk_pngencoder_filterflags_t,
             :fZLibLevel,             :int,
             :fComments,              :pointer,
             :fICCProfile,            :pointer,
             :fICCProfileDescription, :pointer
    end

    # JPEG Encoder
    enum :sk_jpegencoder_downsample_t, [
      :downsample_420, 0,
      :downsample_422, 1,
      :downsample_444, 2
    ]

    enum :sk_jpegencoder_alphaoption_t, [
      :ignore, 0,
      :blend_on_black, 1
    ]

    class SKJpegEncoderOptions < FFI::Struct
      layout :fQuality,               :int,
             :fDownsample,            :sk_jpegencoder_downsample_t,
             :fAlphaOption,           :sk_jpegencoder_alphaoption_t,
             :xmpMetadata,            :pointer,
             :fICCProfile,            :pointer,
             :fICCProfileDescription, :pointer
    end

    # WebP Encoder
    enum :sk_webpencoder_compression_t, [
      :lossy,    0,
      :lossless, 1
    ]

    class SKWebpEncoderOptions < FFI::Struct
      layout :fCompression,           :sk_webpencoder_compression_t,
             :fQuality,               :float,
             :fICCProfile,            :pointer,
             :fICCProfileDescription, :pointer
    end
  end
end
