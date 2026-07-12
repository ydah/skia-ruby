# frozen_string_literal: true

module Skia
  module Native
    # Color
    attach_function :sk_colortype_get_default_8888, [], :sk_colortype_t

    # String
    attach_function :sk_string_destructor, [:sk_string_t], :void
    attach_function :sk_string_get_c_str, [:sk_string_t], :pointer
    attach_function :sk_string_get_size, [:sk_string_t], :size_t
    attach_function :sk_string_new_empty, [], :sk_string_t
    attach_function :sk_string_new_with_copy, %i[pointer size_t], :sk_string_t

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
    attach_function :sk_rrect_inset, %i[sk_rrect_t float float], :void
    attach_function :sk_rrect_outset, %i[sk_rrect_t float float], :void
    attach_function :sk_rrect_offset, %i[sk_rrect_t float float], :void
  end
end
