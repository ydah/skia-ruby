# frozen_string_literal: true

module Skia
  class Paint < Base
    def initialize(ptr = nil, effect_owners: nil)
      super(ptr || Native.sk_paint_new, :sk_paint_delete)
      @effect_owners = effect_owners || {}
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
      return @effect_owners[:shader] if @effect_owners.key?(:shader)

      ptr = Native.sk_paint_get_shader(@ptr)
      return nil if ptr.nil? || ptr.null?

      Shader.wrap(ptr, owner: self)
    end

    def shader=(value)
      Native.sk_paint_set_shader(@ptr, value&.ptr)
      @effect_owners[:shader] = value
    end

    def mask_filter
      return @effect_owners[:mask_filter] if @effect_owners.key?(:mask_filter)

      ptr = Native.sk_paint_get_maskfilter(@ptr)
      return nil if ptr.nil? || ptr.null?

      MaskFilter.wrap(ptr, owner: self)
    end

    def mask_filter=(value)
      Native.sk_paint_set_maskfilter(@ptr, value&.ptr)
      @effect_owners[:mask_filter] = value
    end

    def color_filter
      return @effect_owners[:color_filter] if @effect_owners.key?(:color_filter)

      ptr = Native.sk_paint_get_colorfilter(@ptr)
      return nil if ptr.nil? || ptr.null?

      ColorFilter.wrap(ptr, owner: self)
    end

    def color_filter=(value)
      Native.sk_paint_set_colorfilter(@ptr, value&.ptr)
      @effect_owners[:color_filter] = value
    end

    def image_filter
      return @effect_owners[:image_filter] if @effect_owners.key?(:image_filter)

      ptr = Native.sk_paint_get_imagefilter(@ptr)
      return nil if ptr.nil? || ptr.null?

      ImageFilter.wrap(ptr, owner: self)
    end

    def image_filter=(value)
      Native.sk_paint_set_imagefilter(@ptr, value&.ptr)
      @effect_owners[:image_filter] = value
    end

    def path_effect
      return @effect_owners[:path_effect] if @effect_owners.key?(:path_effect)

      ptr = Native.sk_paint_get_path_effect(@ptr)
      return nil if ptr.nil? || ptr.null?

      PathEffect.wrap(ptr, owner: self)
    end

    def path_effect=(value)
      Native.sk_paint_set_path_effect(@ptr, value&.ptr)
      @effect_owners[:path_effect] = value
    end

    def clone
      self.class.new(Native.sk_paint_clone(@ptr), effect_owners: @effect_owners.dup)
    end

    def reset
      Native.sk_paint_reset(@ptr)
      @effect_owners.clear
      self
    end

    def with(**options)
      cloned = clone
      options.each { |k, v| cloned.send(:"#{k}=", v) }
      cloned
    end
  end
end
