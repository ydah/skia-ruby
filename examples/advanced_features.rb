#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/skia'

info = Skia::ImageInfo.new(
  width: 640,
  height: 360,
  color_type: :rgba_8888,
  alpha_type: :premul,
  color_space: Skia::ColorSpace.srgb
)
surface = Skia::Surface.make_raster(image_info: info)

surface.draw do |canvas|
  canvas.clear(Skia::Color::WHITE)

  rrect = Skia::RRect.from_rect_xy(Skia::Rect.from_xywh(40, 40, 560, 200), 28)
  shader = Skia::Shader.two_point_conical_gradient(
    Skia::Point.new(120, 100),
    8.0,
    Skia::Point.new(360, 220),
    260.0,
    [Skia::Color::BLUE, Skia::Color::CYAN, Skia::Color::MAGENTA]
  )

  fill = Skia::Paint.new
  fill.antialias = true
  fill.shader = shader
  canvas.draw_rrect(rrect, fill)

  stroke = Skia::Paint.new
  stroke.antialias = true
  stroke.style = :stroke
  stroke.stroke_width = 3.0
  stroke.color = Skia::Color::BLACK
  stroke.path_effect = Skia::PathEffect.dash([10.0, 6.0], phase: 2.0)
  canvas.draw_rrect(rrect.clone.inset(4, 4), stroke)

  font = Skia::Font.new(nil, 48)
  blob = Skia::TextBlob.from_text('Skia Ruby', font, x: 60, y: 300)
  text_paint = Skia::Paint.new
  text_paint.antialias = true
  text_paint.color = Skia::Color::BLACK
  canvas.draw_text_blob(blob, 0, 0, text_paint) if blob
end

surface.save_png('advanced_features.png')
pixels = surface.read_pixels(width: 64, height: 64)
puts "Saved advanced_features.png (sample bytes: #{pixels.bytesize})"
