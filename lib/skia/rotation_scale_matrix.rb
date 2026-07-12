# frozen_string_literal: true

module Skia
  class RotationScaleMatrix
    attr_reader :scale_cosine, :scale_sine, :translate_x, :translate_y

    def initialize(scale_cosine, scale_sine, translate_x, translate_y)
      @scale_cosine = scale_cosine.to_f
      @scale_sine = scale_sine.to_f
      @translate_x = translate_x.to_f
      @translate_y = translate_y.to_f
    end

    def self.identity
      new(1, 0, 0, 0)
    end

    def self.translation(x, y)
      new(1, 0, x, y)
    end

    def self.create(scale:, radians:, translate_x:, translate_y:, anchor_x: 0, anchor_y: 0)
      sine = Math.sin(radians) * scale
      cosine = Math.cos(radians) * scale
      x = translate_x - (cosine * anchor_x) + (sine * anchor_y)
      y = translate_y - (sine * anchor_x) - (cosine * anchor_y)
      new(cosine, sine, x, y)
    end

    def to_struct
      struct = Native::SKRotationScaleMatrix.new
      struct[:scos] = @scale_cosine
      struct[:ssin] = @scale_sine
      struct[:tx] = @translate_x
      struct[:ty] = @translate_y
      struct
    end
  end
end
