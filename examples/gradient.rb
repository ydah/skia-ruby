#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/skia'

surface = Skia::Surface.make_raster(400, 400)

surface.draw do |canvas|
  canvas.clear(Skia::Color::WHITE)

  colors = [Skia::Color::RED, Skia::Color::YELLOW, Skia::Color::BLUE]
  shader = Skia::Shader.linear_gradient(
    Skia::Point.new(0, 0),
    Skia::Point.new(400, 0),
    colors
  )

  paint = Skia::Paint.new
  paint.shader = shader
  canvas.draw_rect(Skia::Rect.from_wh(400, 200), paint)

  radial_shader = Skia::Shader.radial_gradient(
    Skia::Point.new(200, 300),
    100,
    [Skia::Color::WHITE, Skia::Color::BLUE]
  )
  paint.shader = radial_shader
  canvas.draw_circle(200, 300, 100, paint)
end

surface.save_png('gradient.png')
puts 'Saved to gradient.png'
