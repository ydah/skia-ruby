# frozen_string_literal: true

module Skia
  class ColorFilter < Base
    def initialize(ptr, owner: nil)
      super(ptr, owner ? nil : :sk_colorfilter_unref, owner: owner)
    end

    def self.wrap(ptr, owner: nil)
      return nil if ptr.nil? || ptr.null?

      new(ptr, owner: owner)
    end

    def self.mode(color, blend_mode = :src_over)
      color_value = color.is_a?(Color) ? color.to_i : color
      ptr = Native.sk_colorfilter_new_mode(color_value, blend_mode)
      raise Error, 'Failed to create color filter' if ptr.nil? || ptr.null?

      new(ptr)
    end
  end
end
