# frozen_string_literal: true

module Skia
  module Native
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
    attach_function :sk_colorfilter_new_lighting, %i[sk_color_t sk_color_t], :sk_color_filter_t
    attach_function :sk_colorfilter_new_compose, %i[sk_color_filter_t sk_color_filter_t], :sk_color_filter_t
    attach_function :sk_colorfilter_new_lerp, %i[float sk_color_filter_t sk_color_filter_t], :sk_color_filter_t
    attach_function :sk_colorfilter_new_color_matrix, [:pointer], :sk_color_filter_t
    attach_function :sk_colorfilter_new_hsla_matrix, [:pointer], :sk_color_filter_t
    attach_function :sk_colorfilter_new_srgb_to_linear_gamma, [], :sk_color_filter_t
    attach_function :sk_colorfilter_new_linear_to_srgb_gamma, [], :sk_color_filter_t
    attach_function :sk_colorfilter_new_luma_color, [], :sk_color_filter_t
    attach_function :sk_colorfilter_new_table, [:pointer], :sk_color_filter_t
    attach_function :sk_colorfilter_new_table_argb, %i[pointer pointer pointer pointer], :sk_color_filter_t
    attach_function :sk_colorfilter_unref, [:sk_color_filter_t], :void

    # Blender
    attach_function :sk_blender_new_mode, [:sk_blend_mode_t], :sk_blender_t
    attach_function :sk_blender_new_arithmetic, %i[float float float float bool], :sk_blender_t
    attach_function :sk_blender_unref, [:sk_blender_t], :void

    # ImageFilter
    attach_function :sk_imagefilter_new_blur,
                    [:float, :float, :sk_shader_tilemode_t, :sk_image_filter_t, SKRect.ptr], :sk_image_filter_t
    attach_function :sk_imagefilter_unref, [:sk_image_filter_t], :void

    # PathEffect
    attach_function :sk_path_effect_create_dash, %i[pointer int float], :sk_path_effect_t
    attach_function :sk_path_effect_unref, [:sk_path_effect_t], :void

    # RuntimeEffect
    optional_attach_function :sk_runtimeeffect_make_for_shader, %i[sk_string_t sk_string_t], :sk_runtimeeffect_t
    optional_attach_function :sk_runtimeeffect_make_for_color_filter, %i[sk_string_t sk_string_t], :sk_runtimeeffect_t
    optional_attach_function :sk_runtimeeffect_make_for_blender, %i[sk_string_t sk_string_t], :sk_runtimeeffect_t
    optional_attach_function :sk_runtimeeffect_make_shader,
                             [:sk_runtimeeffect_t, :sk_data_t, :pointer, :size_t, SKMatrix.ptr], :sk_shader_t
    optional_attach_function :sk_runtimeeffect_make_color_filter,
                             %i[sk_runtimeeffect_t sk_data_t pointer size_t], :sk_color_filter_t
    optional_attach_function :sk_runtimeeffect_make_blender,
                             %i[sk_runtimeeffect_t sk_data_t pointer size_t], :sk_blender_t
    optional_attach_function :sk_runtimeeffect_get_uniform_byte_size, [:sk_runtimeeffect_t], :size_t
    optional_attach_function :sk_runtimeeffect_get_uniforms_size, [:sk_runtimeeffect_t], :size_t
    optional_attach_function :sk_runtimeeffect_get_uniform_name, %i[sk_runtimeeffect_t int sk_string_t], :void
    optional_attach_function :sk_runtimeeffect_get_children_size, [:sk_runtimeeffect_t], :size_t
    optional_attach_function :sk_runtimeeffect_get_child_name, %i[sk_runtimeeffect_t int sk_string_t], :void
    optional_attach_function :sk_runtimeeffect_unref, [:sk_runtimeeffect_t], :void
  end
end
