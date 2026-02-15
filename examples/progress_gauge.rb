#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/skia'

def draw_circular_progress(canvas, cx, cy, radius, progress, label, color)
  paint = Skia::Paint.new
  paint.antialias = true
  paint.style = :stroke
  paint.stroke_width = 12
  paint.stroke_cap = :round

  paint.color = Skia::Color.rgb(230, 230, 230)
  canvas.draw_circle(cx, cy, radius, paint)

  paint.color = color
  rect = Skia::Rect.from_xywh(cx - radius, cy - radius, radius * 2, radius * 2)

  path = Skia::Path.new
  start_angle = -90
  sweep_angle = progress * 360 / 100.0
  path.arc_to_with_oval(rect, start_angle, sweep_angle, true)
  canvas.draw_path(path, paint)

  paint.style = :fill
  paint.color = Skia::Color.rgb(50, 50, 50)
  font_value = Skia::Font.new(nil, radius * 0.5)
  value_text = "#{progress.to_i}%"
  text_width, = font_value.measure_text(value_text)
  canvas.draw_text(value_text, cx - text_width / 2, cy + radius * 0.15, font_value, paint)

  font_label = Skia::Font.new(nil, radius * 0.25)
  paint.color = Skia::Color.rgb(120, 120, 120)
  label_width, = font_label.measure_text(label)
  canvas.draw_text(label, cx - label_width / 2, cy + radius + 25, font_label, paint)
end

def draw_linear_progress(canvas, x, y, width, height, progress, label, color)
  paint = Skia::Paint.new
  paint.antialias = true

  font = Skia::Font.new(nil, 14.0)
  paint.color = Skia::Color.rgb(80, 80, 80)
  canvas.draw_text(label, x, y - 10, font, paint)

  percent_text = "#{progress.to_i}%"
  text_width, = font.measure_text(percent_text)
  canvas.draw_text(percent_text, x + width - text_width, y - 10, font, paint)

  paint.color = Skia::Color.rgb(230, 230, 230)
  bg_rect = Skia::Rect.from_xywh(x, y, width, height)
  canvas.draw_round_rect(bg_rect, height / 2, paint)

  paint.color = color
  progress_width = width * progress / 100.0
  return unless progress_width > height

  progress_rect = Skia::Rect.from_xywh(x, y, progress_width, height)
  canvas.draw_round_rect(progress_rect, height / 2, paint)
end

WIDTH = 800
HEIGHT = 500

surface = Skia::Surface.make_raster(WIDTH, HEIGHT)

surface.draw do |canvas|
  canvas.clear(Skia::Color.rgb(245, 247, 250))

  paint = Skia::Paint.new
  paint.antialias = true

  font_title = Skia::Font.new(nil, 28.0)
  paint.color = Skia::Color.rgb(50, 50, 50)
  canvas.draw_text('System Dashboard', 30, 45, font_title, paint)

  draw_circular_progress(canvas, 130, 180, 70, 78, 'CPU Usage', Skia::Color.rgb(59, 130, 246))
  draw_circular_progress(canvas, 310, 180, 70, 45, 'Memory', Skia::Color.rgb(16, 185, 129))
  draw_circular_progress(canvas, 490, 180, 70, 92, 'Disk', Skia::Color.rgb(245, 158, 11))
  draw_circular_progress(canvas, 670, 180, 70, 23, 'Network', Skia::Color.rgb(139, 92, 246))

  y_start = 320
  bar_height = 16
  bar_spacing = 55

  tasks = [
    { label: 'Project Alpha', progress: 85, color: Skia::Color.rgb(59, 130, 246) },
    { label: 'Project Beta', progress: 60, color: Skia::Color.rgb(16, 185, 129) },
    { label: 'Project Gamma', progress: 35, color: Skia::Color.rgb(245, 158, 11) }
  ]

  tasks.each_with_index do |task, i|
    draw_linear_progress(
      canvas,
      50, y_start + (i * bar_spacing),
      WIDTH - 100, bar_height,
      task[:progress], task[:label], task[:color]
    )
  end
end

surface.save_png('dashboard.png')
puts 'Saved to dashboard.png'
