#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/skia'

Skia::Document.create_pdf('output.pdf') do |doc|
  doc.begin_page(612, 792) do |canvas|
    canvas.clear(Skia::Color::WHITE)

    font = Skia::Font.new(nil, 36.0)
    paint = Skia::Paint.new
    paint.antialias = true
    paint.color = Skia::Color::BLACK

    canvas.draw_text('Hello, PDF!', 50, 100, font, paint)

    paint.color = Skia::Color::RED
    paint.style = :fill
    canvas.draw_rect(Skia::Rect.from_xywh(50, 150, 200, 100), paint)

    paint.color = Skia::Color::BLUE
    canvas.draw_circle(400, 300, 80, paint)
  end

  doc.begin_page(612, 792) do |canvas|
    canvas.clear(Skia::Color::WHITE)

    font = Skia::Font.new(nil, 24.0)
    paint = Skia::Paint.new
    paint.antialias = true
    paint.color = Skia::Color::BLACK

    canvas.draw_text('Page 2', 50, 100, font, paint)

    path = Skia::Path.build do
      move_to 100, 200
      line_to 200, 400
      line_to 50, 400
      close
    end

    paint.color = Skia::Color::GREEN
    paint.style = :fill
    canvas.draw_path(path, paint)
  end
end

puts 'Saved to output.pdf'
