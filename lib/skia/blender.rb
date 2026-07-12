# frozen_string_literal: true

module Skia
  class Blender < Base
    def initialize(ptr, owned: true, owner: nil)
      super(ptr, owned ? :sk_blender_unref : nil, owner: owner)
    end

    def self.wrap(ptr, owner: nil)
      return nil if ptr.nil? || ptr.null?

      new(ptr, owned: false, owner: owner)
    end

    def self.mode(blend_mode)
      ptr = Native.sk_blender_new_mode(blend_mode)
      raise Error, 'Failed to create blend mode blender' if ptr.nil? || ptr.null?

      new(ptr, owned: false)
    end

    def self.arithmetic(k1, k2, k3, k4, enforce_premul: false)
      ptr = Native.sk_blender_new_arithmetic(k1.to_f, k2.to_f, k3.to_f, k4.to_f, enforce_premul)
      raise Error, 'Failed to create arithmetic blender' if ptr.nil? || ptr.null?

      new(ptr)
    end
  end
end
