# frozen_string_literal: true

module Skia
  class Matrix
    attr_accessor :scale_x, :skew_x, :trans_x, :skew_y, :scale_y, :trans_y, :persp0, :persp1, :persp2

    def initialize(scale_x: 1.0, skew_x: 0.0, trans_x: 0.0,
                   skew_y: 0.0, scale_y: 1.0, trans_y: 0.0,
                   persp0: 0.0, persp1: 0.0, persp2: 1.0)
      @scale_x = scale_x.to_f
      @skew_x = skew_x.to_f
      @trans_x = trans_x.to_f
      @skew_y = skew_y.to_f
      @scale_y = scale_y.to_f
      @trans_y = trans_y.to_f
      @persp0 = persp0.to_f
      @persp1 = persp1.to_f
      @persp2 = persp2.to_f
    end

    def self.identity
      new
    end

    def self.translate(dx, dy)
      new(trans_x: dx.to_f, trans_y: dy.to_f)
    end

    def self.scale(sx, sy = sx)
      new(scale_x: sx.to_f, scale_y: sy.to_f)
    end

    def self.rotate(degrees, px = 0.0, py = 0.0)
      radians = degrees * Math::PI / 180.0
      cos = Math.cos(radians)
      sin = Math.sin(radians)

      if px.zero? && py.zero?
        new(scale_x: cos, skew_x: -sin, skew_y: sin, scale_y: cos)
      else
        new(
          scale_x: cos,
          skew_x: -sin,
          trans_x: px - px * cos + py * sin,
          skew_y: sin,
          scale_y: cos,
          trans_y: py - px * sin - py * cos
        )
      end
    end

    def self.skew(sx, sy)
      new(skew_x: sx.to_f, skew_y: sy.to_f)
    end

    def self.from_struct(struct)
      new(
        scale_x: struct[:scaleX],
        skew_x: struct[:skewX],
        trans_x: struct[:transX],
        skew_y: struct[:skewY],
        scale_y: struct[:scaleY],
        trans_y: struct[:transY],
        persp0: struct[:persp0],
        persp1: struct[:persp1],
        persp2: struct[:persp2]
      )
    end

    def to_struct
      struct = Native::SKMatrix.new
      struct[:scaleX] = @scale_x
      struct[:skewX] = @skew_x
      struct[:transX] = @trans_x
      struct[:skewY] = @skew_y
      struct[:scaleY] = @scale_y
      struct[:transY] = @trans_y
      struct[:persp0] = @persp0
      struct[:persp1] = @persp1
      struct[:persp2] = @persp2
      struct
    end

    # Convert 3x3 matrix to 4x4 matrix for canvas operations
    def to_struct44
      struct = Native::SKMatrix44.new
      struct[:m00] = @scale_x
      struct[:m01] = @skew_x
      struct[:m02] = 0.0
      struct[:m03] = @trans_x
      struct[:m10] = @skew_y
      struct[:m11] = @scale_y
      struct[:m12] = 0.0
      struct[:m13] = @trans_y
      struct[:m20] = 0.0
      struct[:m21] = 0.0
      struct[:m22] = 1.0
      struct[:m23] = 0.0
      struct[:m30] = @persp0
      struct[:m31] = @persp1
      struct[:m32] = 0.0
      struct[:m33] = @persp2
      struct
    end

    # Create Matrix from 4x4 struct
    def self.from_struct44(struct)
      new(
        scale_x: struct[:m00],
        skew_x: struct[:m01],
        trans_x: struct[:m03],
        skew_y: struct[:m10],
        scale_y: struct[:m11],
        trans_y: struct[:m13],
        persp0: struct[:m30],
        persp1: struct[:m31],
        persp2: struct[:m33]
      )
    end

    def *(other)
      self.class.new(
        scale_x: @scale_x * other.scale_x + @skew_x * other.skew_y,
        skew_x: @scale_x * other.skew_x + @skew_x * other.scale_y,
        trans_x: @scale_x * other.trans_x + @skew_x * other.trans_y + @trans_x,
        skew_y: @skew_y * other.scale_x + @scale_y * other.skew_y,
        scale_y: @skew_y * other.skew_x + @scale_y * other.scale_y,
        trans_y: @skew_y * other.trans_x + @scale_y * other.trans_y + @trans_y,
        persp0: @persp0 * other.scale_x + @persp1 * other.skew_y + @persp2 * other.persp0,
        persp1: @persp0 * other.skew_x + @persp1 * other.scale_y + @persp2 * other.persp1,
        persp2: @persp0 * other.trans_x + @persp1 * other.trans_y + @persp2 * other.persp2
      )
    end

    def transform_point(point)
      x = point.x * @scale_x + point.y * @skew_x + @trans_x
      y = point.x * @skew_y + point.y * @scale_y + @trans_y
      Point.new(x, y)
    end

    def identity?
      @scale_x == 1.0 && @skew_x == 0.0 && @trans_x == 0.0 &&
        @skew_y == 0.0 && @scale_y == 1.0 && @trans_y == 0.0 &&
        @persp0 == 0.0 && @persp1 == 0.0 && @persp2 == 1.0
    end

    def ==(other)
      return false unless other.is_a?(Matrix)

      @scale_x == other.scale_x && @skew_x == other.skew_x && @trans_x == other.trans_x &&
        @skew_y == other.skew_y && @scale_y == other.scale_y && @trans_y == other.trans_y &&
        @persp0 == other.persp0 && @persp1 == other.persp1 && @persp2 == other.persp2
    end

    def to_a
      [
        [@scale_x, @skew_x, @trans_x],
        [@skew_y, @scale_y, @trans_y],
        [@persp0, @persp1, @persp2]
      ]
    end
  end
end
