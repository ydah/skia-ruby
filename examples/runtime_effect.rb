#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/skia'

sksl = <<~SKSL
  half4 main(float2 coord) {
    half r = coord.x / 640.0;
    half g = coord.y / 360.0;
    return half4(r, g, 0.35, 1.0);
  }
SKSL

effect = Skia::RuntimeEffect.make_for_shader(sksl)
shader = effect.make_shader

surface = Skia::Surface.make_raster(640, 360)
paint = Skia::Paint.new
paint.shader = shader

surface.draw do |canvas|
  canvas.draw_rect(Skia::Rect.from_wh(640, 360), paint)
end

surface.save_png('runtime_effect.png')
puts 'Saved runtime_effect.png'
