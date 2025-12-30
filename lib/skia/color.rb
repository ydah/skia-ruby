# frozen_string_literal: true

module Skia
  class Color
    attr_reader :value

    def initialize(r_or_value = 0, g = nil, b = nil, a = 255)
      @value = if g.nil? && b.nil?
                 r_or_value.is_a?(Integer) ? r_or_value : 0xFF000000
               else
                 ((a & 0xFF) << 24) | ((r_or_value & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF)
               end
    end

    def self.argb(a, r, g, b)
      new(r, g, b, a)
    end

    def self.rgb(r, g, b)
      new(r, g, b, 255)
    end

    def self.from_hex(hex_string)
      hex = hex_string.delete_prefix('#')
      case hex.length
      when 6
        new(hex.to_i(16) | 0xFF000000)
      when 8
        new(hex.to_i(16))
      else
        raise ArgumentError, "Invalid hex color format: #{hex_string}"
      end
    end

    def alpha
      (@value >> 24) & 0xFF
    end

    def red
      (@value >> 16) & 0xFF
    end

    def green
      (@value >> 8) & 0xFF
    end

    def blue
      @value & 0xFF
    end

    def to_i
      @value
    end

    def to_hex
      format('#%08X', @value)
    end

    def with_alpha(a)
      self.class.new(red, green, blue, a)
    end

    def ==(other)
      return false unless other.is_a?(Color)

      @value == other.value
    end

    TRANSPARENT = new(0x00000000)
    BLACK = new(0xFF000000)
    WHITE = new(0xFFFFFFFF)
    RED = new(0xFFFF0000)
    GREEN = new(0xFF00FF00)
    BLUE = new(0xFF0000FF)
    YELLOW = new(0xFFFFFF00)
    CYAN = new(0xFF00FFFF)
    MAGENTA = new(0xFFFF00FF)
    GRAY = new(0xFF808080)
    LIGHT_GRAY = new(0xFFC0C0C0)
    DARK_GRAY = new(0xFF404040)
  end
end
