#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/skia'

font = Skia::Font.new(nil, 22)
paint = Skia::Paint.new
paint.antialias = true
paint.color = Skia::Color::BLACK

text = 'Skia textlayout paragraph sample in Ruby.'

begin
  shaped = Skia::Textlayout::Shaper.shape(text, font)
  paragraph = Skia::Textlayout::Paragraph.new(text, font: font, paint: paint)
  paragraph.layout(420)
rescue Skia::UnsupportedOperationError => e
  warn e.message
  warn 'Current libSkiaSharp does not expose textlayout/paragraph symbols.'
  exit 0
end

surface = Skia::Surface.make_raster(480, 180)
surface.draw do |canvas|
  canvas.clear(Skia::Color::WHITE)
  paragraph.draw(canvas, 24, 48)
  puts "Shaped glyph count: #{shaped.glyphs.length}"
end

surface.save_png('textlayout.png')
puts 'Saved textlayout.png'
