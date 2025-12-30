#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/skia'

bounds = Skia::Rect.from_xywh(0, 0, 200, 200)
picture = Skia::Picture.record(bounds) do |canvas|
  paint = Skia::Paint.new
  paint.antialias = true

  paint.color = Skia::Color::RED
  paint.style = :fill
  canvas.draw_circle(100, 100, 80, paint)

  paint.color = Skia::Color::BLUE
  paint.style = :stroke
  paint.stroke_width = 5
  canvas.draw_circle(100, 100, 80, paint)
end

puts 'Recorded picture:'
puts "  Unique ID: #{picture.unique_id}"
puts "  Cull rect: #{picture.cull_rect.inspect}"
puts "  Approximate op count: #{picture.approximate_op_count}"
puts "  Approximate bytes used: #{picture.approximate_bytes_used}"

data = picture.serialize
puts "  Serialized size: #{data.size} bytes"

loaded_picture = Skia::Picture.from_data(data)
puts "  Loaded picture unique ID: #{loaded_picture.unique_id}"

surface = Skia::Surface.make_raster(640, 480)
surface.draw do |canvas|
  canvas.clear(Skia::Color::WHITE)

  canvas.with_save do
    canvas.translate(50, 50)
    picture.playback(canvas)
  end

  canvas.with_save do
    canvas.translate(300, 50)
    canvas.scale(0.5, 0.5)
    picture.playback(canvas)
  end

  canvas.with_save do
    canvas.translate(50, 280)
    canvas.scale(1.5, 1.5)
    picture.playback(canvas)
  end

  canvas.with_save do
    canvas.translate(400, 280)
    canvas.rotate(45, 100, 100)
    picture.playback(canvas)
  end
end

surface.save_png('picture_output.png')
puts 'Saved to picture_output.png'
