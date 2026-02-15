# frozen_string_literal: true

module Skia
  class Rect
    attr_accessor :left, :top, :right, :bottom

    def initialize(left = 0.0, top = 0.0, right = 0.0, bottom = 0.0)
      @left = left.to_f
      @top = top.to_f
      @right = right.to_f
      @bottom = bottom.to_f
    end

    def self.from_xywh(x, y, width, height)
      new(x, y, x + width, y + height)
    end

    def self.from_wh(width, height)
      new(0, 0, width, height)
    end

    def self.from_struct(struct)
      new(struct[:left], struct[:top], struct[:right], struct[:bottom])
    end

    def to_struct
      struct = Native::SKRect.new
      struct[:left] = @left
      struct[:top] = @top
      struct[:right] = @right
      struct[:bottom] = @bottom
      struct
    end

    def width
      @right - @left
    end

    def height
      @bottom - @top
    end

    def center_x
      (@left + @right) / 2.0
    end

    def center_y
      (@top + @bottom) / 2.0
    end

    def center
      Point.new(center_x, center_y)
    end

    def empty?
      @left >= @right || @top >= @bottom
    end

    def contains?(x, y)
      x >= @left && x < @right && y >= @top && y < @bottom
    end

    def contains_rect?(other)
      @left <= other.left && @top <= other.top &&
        @right >= other.right && @bottom >= other.bottom
    end

    def intersects?(other)
      @left < other.right && other.left < @right &&
        @top < other.bottom && other.top < @bottom
    end

    def intersect(other)
      return nil unless intersects?(other)

      self.class.new(
        [@left, other.left].max,
        [@top, other.top].min,
        [@right, other.right].min,
        [@bottom, other.bottom].max
      )
    end

    def union(other)
      self.class.new(
        [@left, other.left].min,
        [@top, other.top].min,
        [@right, other.right].max,
        [@bottom, other.bottom].max
      )
    end

    def offset(dx, dy)
      self.class.new(@left + dx, @top + dy, @right + dx, @bottom + dy)
    end

    def offset!(dx, dy)
      @left += dx
      @top += dy
      @right += dx
      @bottom += dy
      self
    end

    def inset(dx, dy)
      self.class.new(@left + dx, @top + dy, @right - dx, @bottom - dy)
    end

    def ==(other)
      return false unless other.is_a?(Rect)

      @left == other.left && @top == other.top &&
        @right == other.right && @bottom == other.bottom
    end

    def to_a
      [@left, @top, @right, @bottom]
    end
  end

  class IRect
    attr_accessor :left, :top, :right, :bottom

    def initialize(left = 0, top = 0, right = 0, bottom = 0)
      @left = left.to_i
      @top = top.to_i
      @right = right.to_i
      @bottom = bottom.to_i
    end

    def self.from_xywh(x, y, width, height)
      new(x, y, x + width, y + height)
    end

    def self.from_wh(width, height)
      new(0, 0, width, height)
    end

    def self.from_struct(struct)
      new(struct[:left], struct[:top], struct[:right], struct[:bottom])
    end

    def to_struct
      struct = Native::SKIRect.new
      struct[:left] = @left
      struct[:top] = @top
      struct[:right] = @right
      struct[:bottom] = @bottom
      struct
    end

    def width
      @right - @left
    end

    def height
      @bottom - @top
    end

    def empty?
      @left >= @right || @top >= @bottom
    end

    def ==(other)
      return false unless other.is_a?(IRect)

      @left == other.left && @top == other.top &&
        @right == other.right && @bottom == other.bottom
    end

    def to_a
      [@left, @top, @right, @bottom]
    end

    def to_rect
      Rect.new(@left.to_f, @top.to_f, @right.to_f, @bottom.to_f)
    end
  end
end
