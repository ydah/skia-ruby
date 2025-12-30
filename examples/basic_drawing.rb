#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/skia'

surface = Skia::Surface.make_raster(640, 480)

surface.draw do |canvas|
  canvas.clear(Skia::Color::WHITE)

  paint = Skia::Paint.new
  paint.antialias = true

  paint.color = Skia::Color::RED
  paint.style = :fill
  canvas.draw_rect(Skia::Rect.from_xywh(50, 50, 150, 100), paint)

  paint.color = Skia::Color::BLUE
  canvas.draw_circle(400, 200, 80, paint)

  paint.color = Skia::Color::GREEN
  paint.style = :stroke
  paint.stroke_width = 3
  canvas.draw_oval(Skia::Rect.from_xywh(200, 300, 200, 100), paint)

  path = Skia::Path.build do
    move_to 100, 300
    line_to 200, 400
    line_to 50, 400
    close
  end
  paint.color = Skia::Color.rgb(255, 165, 0)
  paint.style = :fill
  canvas.draw_path(path, paint)

  paint.color = Skia::Color::MAGENTA
  paint.style = :stroke
  paint.stroke_width = 2
  canvas.draw_line(500, 50, 600, 150, paint)
end

surface.save_png('output.png')
puts 'Saved to output.png'
