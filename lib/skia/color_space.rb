# frozen_string_literal: true

module Skia
  class ColorSpace < Base
    def initialize(ptr, retain: false)
      Native.sk_colorspace_ref(ptr) if retain
      super(ptr, :sk_colorspace_unref)
    end

    def self.wrap(ptr, retain: false)
      return nil if ptr.nil? || ptr.null?

      new(ptr, retain: retain)
    end

    def self.srgb
      ptr = Native.sk_colorspace_new_srgb
      raise Error, 'Failed to create sRGB color space' if ptr.nil? || ptr.null?

      new(ptr)
    end

    def self.srgb_linear
      ptr = Native.sk_colorspace_new_srgb_linear
      raise Error, 'Failed to create linear sRGB color space' if ptr.nil? || ptr.null?

      new(ptr)
    end

    def srgb?
      Native.sk_colorspace_is_srgb(@ptr)
    end

    def linear_gamma?
      Native.sk_colorspace_gamma_is_linear(@ptr)
    end

    def ==(other)
      return false unless other.is_a?(ColorSpace)

      Native.sk_colorspace_equals(@ptr, other.ptr)
    end
  end
end
