#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/skia"

surface = Skia::Surface.make_raster(640, 480)

surface.draw do |canvas|
  canvas.clear(Skia::Color::WHITE)

  font = Skia::Font.new(nil, 48.0)

  paint = Skia::Paint.new
  paint.antialias = true
  paint.color = Skia::Color::BLACK

  canvas.draw_text("Hello, Skia!", 50, 100, font, paint)

  paint.color = Skia::Color::RED
  canvas.draw_text("Red Text", 50, 180, font, paint)

  paint.color = Skia::Color::BLUE
  canvas.draw_text("Blue Text", 50, 260, font, paint)

  small_font = Skia::Font.new(nil, 24.0)
  paint.color = Skia::Color::GREEN
  canvas.draw_text("Smaller green text", 50, 320, small_font, paint)

  width, bounds = font.measure_text("Measured Text")
  paint.color = Skia::Color.argb(100, 255, 200, 0)
  paint.style = :fill
  measured_rect = Skia::Rect.from_xywh(50, 380 + bounds.top, width, bounds.height)
  canvas.draw_rect(measured_rect, paint)

  paint.color = Skia::Color::BLACK
  canvas.draw_text("Measured Text", 50, 380, font, paint)
end

surface.save_png("text_output.png")
puts "Saved to text_output.png"
