#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/skia'

def generate_avatar(name, size: 200, output: nil)
  initials = name.split.map { |n| n[0].upcase }.join[0, 2]

  hash = name.chars.map(&:ord).sum
  hue = hash % 360

  c = 0.6
  x = c * (1 - ((hue / 60.0) % 2 - 1).abs)
  m = 0.2

  r, g, b = case hue / 60
            when 0 then [c, x, 0]
            when 1 then [x, c, 0]
            when 2 then [0, c, x]
            when 3 then [0, x, c]
            when 4 then [x, 0, c]
            else [c, 0, x]
            end

  bg_color = Skia::Color.rgb(
    ((r + m) * 255).to_i,
    ((g + m) * 255).to_i,
    ((b + m) * 255).to_i
  )

  surface = Skia::Surface.make_raster(size, size)

  surface.draw do |canvas|
    canvas.clear(Skia::Color::TRANSPARENT)

    paint = Skia::Paint.new
    paint.antialias = true

    paint.color = bg_color
    paint.style = :fill
    canvas.draw_circle(size / 2.0, size / 2.0, size / 2.0, paint)

    font_size = size * 0.4
    font = Skia::Font.new(nil, font_size)
    paint.color = Skia::Color::WHITE

    text_width, text_bounds = font.measure_text(initials)
    metrics = font.metrics
    x = (size - text_width) / 2.0
    y = (size / 2.0) - (metrics.ascent + metrics.descent) / 2.0

    canvas.draw_text(initials, x, y, font, paint)
  end

  output_file = output || "avatar_#{name.downcase.gsub(/\s+/, '_')}.png"
  surface.save_png(output_file)
  puts "Generated: #{output_file}"
  output_file
end

names = [
  'John Doe',
  'Alice Smith',
  'Bob Johnson',
  'Emma Wilson',
  'Michael Brown'
]

puts 'Generating avatars...'
names.each { |name| generate_avatar(name, size: 128) }

generate_avatar('Ruby Developer', size: 256, output: 'avatar_large.png')

puts "\nAll avatars generated!"
