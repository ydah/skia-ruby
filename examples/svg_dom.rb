#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/skia'

svg = <<~SVG
  <svg width="220" height="120" viewBox="0 0 220 120" xmlns="http://www.w3.org/2000/svg">
    <path d="M 20 20 L 200 20 L 200 100 L 20 100 Z" fill="#ffe082" stroke="#ef6c00" stroke-width="4" />
    <path d="M 60 60 L 110 25 L 160 60 L 145 95 L 75 95 Z" fill="#42a5f5" />
  </svg>
SVG

begin
  dom = Skia::Svg::Dom.from_svg(svg)
rescue Skia::UnsupportedOperationError => e
  warn e.message
  warn 'Current libSkiaSharp does not expose SVG path parser symbols.'
  exit 0
end

surface = Skia::Surface.make_raster(240, 140)
surface.draw do |canvas|
  canvas.clear(Skia::Color::WHITE)
  dom.draw(canvas, x: 10, y: 10)
end

surface.save_png('svg_dom.png')
puts 'Saved svg_dom.png'
