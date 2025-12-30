# frozen_string_literal: true

module Skia
  class Typeface < Base
    WEIGHT_NORMAL = 400
    WEIGHT_BOLD = 700
    WIDTH_NORMAL = 5

    def initialize(ptr)
      super(ptr, :sk_typeface_unref)
    end

    def self.from_name(name, weight: WEIGHT_NORMAL, width: WIDTH_NORMAL, slant: :upright)
      style = Native.sk_fontstyle_new(weight, width, slant)
      begin
        ptr = Native.sk_typeface_create_from_name(name, style)
        return nil if ptr.nil? || ptr.null?

        new(ptr)
      ensure
        Native.sk_fontstyle_delete(style) if style && !style.null?
      end
    end

    def self.from_file(path, index = 0)
      ptr = Native.sk_typeface_create_from_file(path, index)
      raise FileNotFoundError, "Failed to load typeface: #{path}" if ptr.nil? || ptr.null?

      new(ptr)
    end

    def self.default
      ptr = Native.sk_typeface_create_default
      return nil if ptr.nil? || ptr.null?

      new(ptr)
    end
  end
end
