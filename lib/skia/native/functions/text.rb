# frozen_string_literal: true

module Skia
  module Native
    # Typeface
    attach_function :sk_typeface_create_from_name, %i[string pointer], :sk_typeface_t
    attach_function :sk_typeface_create_from_file, %i[string int], :sk_typeface_t
    attach_function :sk_typeface_create_default, [], :sk_typeface_t
    attach_function :sk_typeface_unref, [:sk_typeface_t], :void

    # FontManager
    attach_function :sk_fontmgr_create_default, [], :sk_fontmgr_t
    attach_function :sk_fontmgr_unref, [:sk_fontmgr_t], :void
    attach_function :sk_fontmgr_count_families, [:sk_fontmgr_t], :int
    attach_function :sk_fontmgr_get_family_name, %i[sk_fontmgr_t int sk_string_t], :void
    attach_function :sk_fontmgr_match_family_style, %i[sk_fontmgr_t string pointer], :sk_typeface_t
    attach_function :sk_fontmgr_match_family_style_character,
                    %i[sk_fontmgr_t string pointer pointer int int32], :sk_typeface_t
    attach_function :sk_fontmgr_create_from_file, %i[sk_fontmgr_t string int], :sk_typeface_t
    attach_function :sk_fontmgr_create_from_data, %i[sk_fontmgr_t sk_data_t int], :sk_typeface_t

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
    attach_function :sk_font_get_xpos, %i[sk_font_t pointer int pointer float], :void
    attach_function :sk_font_text_to_glyphs,
                    %i[sk_font_t pointer size_t sk_text_encoding_t pointer int], :int
    attach_function :sk_font_measure_text,
                    [:sk_font_t, :pointer, :size_t, :sk_text_encoding_t, SKRect.ptr, :sk_paint_t], :float

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
    attach_function :sk_typeface_get_table_tags, %i[sk_typeface_t pointer], :int
    attach_function :sk_typeface_get_table_size, %i[sk_typeface_t uint32], :size_t
    attach_function :sk_typeface_get_table_data, %i[sk_typeface_t uint32 size_t size_t pointer], :size_t
    attach_function :sk_typeface_copy_table_data, %i[sk_typeface_t uint32], :sk_data_t
  end
end
