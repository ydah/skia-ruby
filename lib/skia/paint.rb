# frozen_string_literal: true

module Skia
  class Paint < Base
    def initialize(ptr = nil)
      super(ptr || Native.sk_paint_new, :sk_paint_delete)
    end

    def antialias?
      Native.sk_paint_is_antialias(@ptr)
    end

    def antialias=(value)
      Native.sk_paint_set_antialias(@ptr, value)
    end

    def color
      Color.new(Native.sk_paint_get_color(@ptr))
    end

    def color=(value)
      color_value = value.is_a?(Color) ? value.to_i : value
      Native.sk_paint_set_color(@ptr, color_value)
    end

    def style
      Native.sk_paint_get_style(@ptr)
    end

    def style=(value)
      Native.sk_paint_set_style(@ptr, value)
    end

    def stroke_width
      Native.sk_paint_get_stroke_width(@ptr)
    end

    def stroke_width=(value)
      Native.sk_paint_set_stroke_width(@ptr, value.to_f)
    end

    def stroke_cap
      Native.sk_paint_get_stroke_cap(@ptr)
    end

    def stroke_cap=(value)
      Native.sk_paint_set_stroke_cap(@ptr, value)
    end

    def stroke_join
      Native.sk_paint_get_stroke_join(@ptr)
    end

    def stroke_join=(value)
      Native.sk_paint_set_stroke_join(@ptr, value)
    end

    def stroke_miter
      Native.sk_paint_get_stroke_miter(@ptr)
    end

    def stroke_miter=(value)
      Native.sk_paint_set_stroke_miter(@ptr, value.to_f)
    end

    def blend_mode
      Native.sk_paint_get_blendmode(@ptr)
    end

    def blend_mode=(value)
      Native.sk_paint_set_blendmode(@ptr, value)
    end

    def shader
      ptr = Native.sk_paint_get_shader(@ptr)
      return nil if ptr.nil? || ptr.null?

      Shader.wrap(ptr)
    end

    def shader=(value)
      Native.sk_paint_set_shader(@ptr, value&.ptr)
    end

    def mask_filter
      ptr = Native.sk_paint_get_maskfilter(@ptr)
      return nil if ptr.nil? || ptr.null?

      MaskFilter.wrap(ptr)
    end

    def mask_filter=(value)
      Native.sk_paint_set_maskfilter(@ptr, value&.ptr)
    end

    def color_filter
      ptr = Native.sk_paint_get_colorfilter(@ptr)
      return nil if ptr.nil? || ptr.null?

      ColorFilter.wrap(ptr)
    end

    def color_filter=(value)
      Native.sk_paint_set_colorfilter(@ptr, value&.ptr)
    end

    def image_filter
      ptr = Native.sk_paint_get_imagefilter(@ptr)
      return nil if ptr.nil? || ptr.null?

      ImageFilter.wrap(ptr)
    end

    def image_filter=(value)
      Native.sk_paint_set_imagefilter(@ptr, value&.ptr)
    end

    def path_effect
      ptr = Native.sk_paint_get_path_effect(@ptr)
      return nil if ptr.nil? || ptr.null?

      PathEffect.wrap(ptr)
    end

    def path_effect=(value)
      Native.sk_paint_set_path_effect(@ptr, value&.ptr)
    end

    def clone
      self.class.new(Native.sk_paint_clone(@ptr))
    end

    def reset
      Native.sk_paint_reset(@ptr)
      self
    end

    def with(**options)
      cloned = clone
      options.each { |k, v| cloned.send(:"#{k}=", v) }
      cloned
    end
  end
end
