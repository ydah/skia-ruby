#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/skia'

def generate_social_card(
  title:,
  author: nil,
  site_name: nil,
  tags: [],
  output: 'social_card.png'
)
  width = 1200
  height = 630

  surface = Skia::Surface.make_raster(width, height)

  surface.draw do |canvas|
    paint = Skia::Paint.new
    paint.antialias = true

    gradient = Skia::Shader.linear_gradient(
      Skia::Point.new(0, 0),
      Skia::Point.new(width, height),
      [
        Skia::Color.rgb(102, 126, 234),
        Skia::Color.rgb(118, 75, 162)
      ]
    )
    paint.shader = gradient
    canvas.draw_rect(Skia::Rect.from_xywh(0, 0, width, height), paint)
    paint.shader = nil

    paint.color = Skia::Color.argb(30, 255, 255, 255)
    canvas.draw_circle(100, 100, 200, paint)
    canvas.draw_circle(1100, 500, 250, paint)
    canvas.draw_circle(900, 50, 100, paint)

    paint.color = Skia::Color::WHITE
    content_rect = Skia::Rect.from_xywh(60, 60, width - 120, height - 120)
    canvas.draw_round_rect(content_rect, 20, paint)

    paint.color = Skia::Color.rgb(30, 30, 30)
    font_title = Skia::Font.new(nil, 52.0)

    max_chars_per_line = 28
    title_lines = []
    words = title.split
    current_line = ''

    words.each do |word|
      test_line = current_line.empty? ? word : "#{current_line} #{word}"
      if test_line.length > max_chars_per_line && !current_line.empty?
        title_lines << current_line
        current_line = word
      else
        current_line = test_line
      end
    end
    title_lines << current_line unless current_line.empty?

    title_y = 160
    title_lines.each_with_index do |line, i|
      canvas.draw_text(line, 100, title_y + (i * 70), font_title, paint)
    end

    if tags.any?
      font_tag = Skia::Font.new(nil, 24.0)
      tag_y = height - 180
      tag_x = 100

      tags.each do |tag|
        tag_text = "##{tag}"
        text_width, = font_tag.measure_text(tag_text)

        paint.color = Skia::Color.rgb(102, 126, 234)
        tag_rect = Skia::Rect.from_xywh(tag_x - 10, tag_y - 25, text_width + 20, 35)
        canvas.draw_round_rect(tag_rect, 17, paint)

        paint.color = Skia::Color::WHITE
        canvas.draw_text(tag_text, tag_x, tag_y, font_tag, paint)

        tag_x += text_width + 30
      end
    end

    if author
      font_author = Skia::Font.new(nil, 28.0)
      paint.color = Skia::Color.rgb(100, 100, 100)
      canvas.draw_text(author, 100, height - 100, font_author, paint)
    end

    if site_name
      font_site = Skia::Font.new(nil, 24.0)
      paint.color = Skia::Color.rgb(150, 150, 150)
      text_width, = font_site.measure_text(site_name)
      canvas.draw_text(site_name, width - 100 - text_width, height - 100, font_site, paint)
    end
  end

  surface.save_png(output)
  puts "Saved to #{output}"
end

generate_social_card(
  title: 'Building Ruby Bindings for Skia Graphics Library with FFI',
  author: '@ruby_dev',
  site_name: 'tech.blog',
  tags: %w[Ruby FFI Graphics],
  output: 'social_card_blog.png'
)

generate_social_card(
  title: 'Conference Session: High Performance 2D Graphics in Ruby',
  author: 'Speaker Name',
  site_name: 'RubyKaigi',
  tags: %w[RubyKaigi Conference],
  output: 'social_card_event.png'
)

puts "\nSocial cards generated!"
