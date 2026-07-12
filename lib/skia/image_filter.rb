# frozen_string_literal: true

module Skia
  class ImageFilter < Base
    def initialize(ptr, owner: nil)
      super(ptr, owner ? nil : :sk_imagefilter_unref, owner: owner)
    end

    def self.wrap(ptr, owner: nil)
      return nil if ptr.nil? || ptr.null?

      new(ptr, owner: owner)
    end

    def self.blur(sigma_x, sigma_y, tile_mode: :decal, input: nil, crop_rect: nil)
      crop_rect_struct = crop_rect&.to_struct
      ptr = Native.sk_imagefilter_new_blur(
        sigma_x.to_f,
        sigma_y.to_f,
        tile_mode,
        input&.ptr,
        crop_rect_struct
      )
      raise Error, 'Failed to create blur image filter' if ptr.nil? || ptr.null?

      new(ptr)
    end
  end
end
