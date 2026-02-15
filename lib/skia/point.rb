# frozen_string_literal: true

module Skia
  class Point
    attr_accessor :x, :y

    def initialize(x = 0.0, y = 0.0)
      @x = x.to_f
      @y = y.to_f
    end

    def self.from_struct(struct)
      new(struct[:x], struct[:y])
    end

    def to_struct
      struct = Native::SKPoint.new
      struct[:x] = @x
      struct[:y] = @y
      struct
    end

    def +(other)
      self.class.new(@x + other.x, @y + other.y)
    end

    def -(other)
      self.class.new(@x - other.x, @y - other.y)
    end

    def *(other)
      self.class.new(@x * other, @y * other)
    end

    def /(other)
      self.class.new(@x / other, @y / other)
    end

    def -@
      self.class.new(-@x, -@y)
    end

    def length
      Math.sqrt(@x * @x + @y * @y)
    end

    def normalize
      len = length
      return self.class.new(0, 0) if len.zero?

      self / len
    end

    def ==(other)
      return false unless other.is_a?(Point)

      @x == other.x && @y == other.y
    end

    def to_a
      [@x, @y]
    end
  end

  class IPoint
    attr_accessor :x, :y

    def initialize(x = 0, y = 0)
      @x = x.to_i
      @y = y.to_i
    end

    def self.from_struct(struct)
      new(struct[:x], struct[:y])
    end

    def to_struct
      struct = Native::SKIPoint.new
      struct[:x] = @x
      struct[:y] = @y
      struct
    end

    def ==(other)
      return false unless other.is_a?(IPoint)

      @x == other.x && @y == other.y
    end

    def to_a
      [@x, @y]
    end
  end
end
