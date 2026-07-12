# frozen_string_literal: true

module Skia
  class MaskFilter < Base
    def initialize(ptr, owner: nil)
      super(ptr, owner ? nil : :sk_maskfilter_unref, owner: owner)
    end

    def self.wrap(ptr, owner: nil)
      return nil if ptr.nil? || ptr.null?

      new(ptr, owner: owner)
    end

    def self.blur(style = :normal, sigma:, respect_ctm: nil)
      ptr = if respect_ctm.nil?
              Native.sk_maskfilter_new_blur(style, sigma.to_f)
            else
              Native.sk_maskfilter_new_blur_with_flags(style, sigma.to_f, respect_ctm)
            end
      raise Error, 'Failed to create blur mask filter' if ptr.nil? || ptr.null?

      new(ptr)
    end
  end
end
