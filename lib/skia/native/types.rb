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
    typedef :pointer, :sk_pixmap_t
    typedef :pointer, :sk_document_t
    typedef :pointer, :sk_picture_t
    typedef :pointer, :sk_picture_recorder_t
    typedef :pointer, :sk_drawable_t

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

    enum :sk_clipop_t, [
      :difference, 0,
      :intersect,  1
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
