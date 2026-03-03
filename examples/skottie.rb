#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/skia'

json = <<~JSON
  {
    "v": "5.5.7",
    "fr": 30,
    "ip": 0,
    "op": 60,
    "w": 256,
    "h": 256,
    "nm": "sample",
    "ddd": 0,
    "assets": [],
    "layers": []
  }
JSON

begin
  animation = Skia::Skottie::Animation.make_from_json(json)
rescue Skia::UnsupportedOperationError => e
  warn e.message
  warn 'Current libSkiaSharp does not expose skottie symbols.'
  exit 0
end

surface = Skia::Surface.make_raster(256, 256)
surface.draw do |canvas|
  canvas.clear(Skia::Color::WHITE)
  animation.render_frame(canvas, frame: 0, rect: Skia::Rect.from_wh(256, 256))
end

surface.save_png('skottie.png')
puts "Animation size: #{animation.size.inspect}, fps: #{animation.fps}, duration: #{animation.duration}"
puts 'Saved skottie.png'
