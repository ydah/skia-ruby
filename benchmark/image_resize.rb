# frozen_string_literal: true

require 'benchmark/ips'
require_relative '../lib/skia'

WIDTH = 1920
HEIGHT = 1080
TARGET_WIDTH = 480
TARGET_HEIGHT = 270
PIXELS = ("\x20\x80\xE0\xFF" * WIDTH * HEIGHT).freeze

skia_surface = Skia::Surface.make_raster_direct(
  WIDTH,
  HEIGHT,
  pixels: PIXELS,
  row_bytes: WIDTH * 4,
  alpha_type: :unpremul
)
skia_image = skia_surface.snapshot

implementations = {
  'skia' => -> { skia_image.resize(TARGET_WIDTH, TARGET_HEIGHT) }
}

begin
  require 'rmagick'
  rmagick_image = Magick::Image.constitute(WIDTH, HEIGHT, 'RGBA', PIXELS.unpack('C*'))
  implementations['rmagick'] = -> { rmagick_image.resize(TARGET_WIDTH, TARGET_HEIGHT) }
rescue LoadError
  warn 'rmagick is not installed; skipping it'
end

begin
  require 'vips'
  vips_image = Vips::Image.new_from_memory(PIXELS, WIDTH, HEIGHT, 4, :uchar)
  implementations['ruby-vips'] = lambda do
    vips_image.resize(TARGET_WIDTH.fdiv(WIDTH), vscale: TARGET_HEIGHT.fdiv(HEIGHT))
  end
rescue LoadError
  warn 'ruby-vips is not installed; skipping it'
end

begin
  require 'cairo'
  cairo_source = Cairo::ImageSurface.new(:argb32, WIDTH, HEIGHT)
  implementations['cairo'] = lambda do
    target = Cairo::ImageSurface.new(:argb32, TARGET_WIDTH, TARGET_HEIGHT)
    context = Cairo::Context.new(target)
    context.scale(TARGET_WIDTH.fdiv(WIDTH), TARGET_HEIGHT.fdiv(HEIGHT))
    context.set_source(cairo_source)
    context.paint
    target
  end
rescue LoadError
  warn 'cairo is not installed; skipping it'
end

Benchmark.ips do |benchmark|
  benchmark.config(time: 5, warmup: 2)
  implementations.each { |name, operation| benchmark.report(name, &operation) }
  benchmark.compare!
end
