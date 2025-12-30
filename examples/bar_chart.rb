#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/skia'

data = {
  'Maguro' => 92,
  'Salmon' => 88,
  'Ebi' => 75,
  'Tamago' => 68,
  'Ika' => 45
}

WIDTH = 600
HEIGHT = 400
MARGIN = { top: 40, right: 30, bottom: 60, left: 80 }.freeze
CHART_WIDTH = WIDTH - MARGIN[:left] - MARGIN[:right]
CHART_HEIGHT = HEIGHT - MARGIN[:top] - MARGIN[:bottom]

surface = Skia::Surface.make_raster(WIDTH, HEIGHT)

surface.draw do |canvas|
  canvas.clear(Skia::Color::WHITE)

  paint = Skia::Paint.new
  paint.antialias = true

  font_title = Skia::Font.new(nil, 20.0)
  paint.color = Skia::Color::BLACK
  canvas.draw_text('Sushi Popularity Ranking', 180, 28, font_title, paint)

  font_axis = Skia::Font.new(nil, 12.0)
  paint.style = :stroke
  paint.stroke_width = 1
  paint.color = Skia::Color.rgb(200, 200, 200)

  max_value = 100
  5.times do |i|
    value = i * 25
    y = MARGIN[:top] + CHART_HEIGHT - (value.to_f / max_value * CHART_HEIGHT)

    canvas.draw_line(MARGIN[:left], y, WIDTH - MARGIN[:right], y, paint)

    paint.style = :fill
    paint.color = Skia::Color::BLACK
    canvas.draw_text(value.to_s, MARGIN[:left] - 35, y + 4, font_axis, paint)
    paint.style = :stroke
    paint.color = Skia::Color.rgb(200, 200, 200)
  end

  bar_width = CHART_WIDTH / data.size * 0.7
  bar_spacing = CHART_WIDTH / data.size

  colors = [
    Skia::Color.rgb(220, 53, 69),
    Skia::Color.rgb(255, 127, 80),
    Skia::Color.rgb(255, 182, 193),
    Skia::Color.rgb(255, 215, 0),
    Skia::Color.rgb(230, 230, 250)
  ]

  data.each_with_index do |(name, value), i|
    x = MARGIN[:left] + (i * bar_spacing) + (bar_spacing - bar_width) / 2
    bar_height = (value.to_f / max_value) * CHART_HEIGHT
    y = MARGIN[:top] + CHART_HEIGHT - bar_height

    paint.style = :fill
    paint.color = colors[i]
    canvas.draw_rect(Skia::Rect.from_xywh(x, y, bar_width, bar_height), paint)

    paint.style = :stroke
    paint.stroke_width = 1
    paint.color = Skia::Color.rgb(100, 100, 100)
    canvas.draw_rect(Skia::Rect.from_xywh(x, y, bar_width, bar_height), paint)

    paint.style = :fill
    paint.color = Skia::Color::BLACK
    text_width, = font_axis.measure_text(name)
    label_x = x + (bar_width - text_width) / 2
    canvas.draw_text(name, label_x, HEIGHT - MARGIN[:bottom] + 20, font_axis, paint)

    value_text = "#{value}%"
    value_width, = font_axis.measure_text(value_text)
    canvas.draw_text(value_text, x + (bar_width - value_width) / 2, y - 8, font_axis, paint)
  end
end

surface.save_png('bar_chart.png')
puts 'Saved to bar_chart.png'
