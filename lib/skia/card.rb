# frozen_string_literal: true

module Skia
  class Card
    DEFAULT_WIDTH = 1200
    DEFAULT_HEIGHT = 630
    DEFAULT_COLORS = [Color.rgb(102, 126, 234), Color.rgb(118, 75, 162)].freeze

    attr_reader :title, :author, :site_name, :tags, :width, :height

    def initialize(title:, author: nil, site_name: nil, tags: [], width: DEFAULT_WIDTH, height: DEFAULT_HEIGHT,
                   colors: DEFAULT_COLORS)
      @title = title.to_s
      @author = author&.to_s
      @site_name = site_name&.to_s
      @tags = Array(tags).map(&:to_s)
      @width = Integer(width)
      @height = Integer(height)
      @colors = Array(colors)
      validate!
    end

    def render
      Surface.make_raster(width, height).tap do |surface|
        surface.draw { |canvas| draw(canvas) }
      end
    end

    def save(path, format: nil, quality: 100)
      render.save(path, format: format, quality: quality)
      self
    end

    private

    def validate!
      raise ArgumentError, 'title must not be empty' if title.empty?
      raise ArgumentError, 'width and height must be positive' unless width.positive? && height.positive?
      raise ArgumentError, 'colors must contain at least two colors' if @colors.length < 2
    end

    def draw(canvas)
      paint = Paint.new
      paint.antialias = true
      draw_background(canvas, paint)
      draw_panel(canvas, paint)
      draw_title(canvas, paint)
      draw_tags(canvas, paint)
      draw_footer(canvas, paint)
    end

    def draw_background(canvas, paint)
      paint.shader = Shader.linear_gradient(Point.new(0, 0), Point.new(width, height), @colors)
      canvas.draw_rect(Rect.from_wh(width, height), paint)
      paint.shader = nil
      paint.color = Color.argb(30, 255, 255, 255)
      canvas.draw_circle(width * 0.08, height * 0.16, height * 0.32, paint)
      canvas.draw_circle(width * 0.92, height * 0.79, height * 0.4, paint)
    end

    def draw_panel(canvas, paint)
      paint.color = Color::WHITE
      canvas.draw_round_rect(Rect.from_xywh(60, 60, width - 120, height - 120), 20, paint)
    end

    def draw_title(canvas, paint)
      font = Font.new(nil, [height * 0.083, 18].max)
      paint.color = Color.rgb(30, 30, 30)
      lines = wrap_text(title, font, width - 200)
      line_height = font.size * 1.35
      lines.first(4).each_with_index do |line, index|
        canvas.draw_text(line, 100, 160 + (index * line_height), font, paint)
      end
    end

    def draw_tags(canvas, paint)
      return if tags.empty?

      font = Font.new(nil, [height * 0.038, 14].max)
      x = 100.0
      baseline = height - 180.0
      tags.each do |tag|
        text = "##{tag}"
        text_width, = font.measure_text(text)
        break if x + text_width + 20 > width - 80

        paint.color = @colors.first
        canvas.draw_round_rect(Rect.from_xywh(x - 10, baseline - font.size, text_width + 20, font.size + 12), 17, paint)
        paint.color = Color::WHITE
        canvas.draw_text(text, x, baseline, font, paint)
        x += text_width + 30
      end
    end

    def draw_footer(canvas, paint)
      font = Font.new(nil, [height * 0.044, 14].max)
      paint.color = Color.rgb(100, 100, 100)
      canvas.draw_text(author, 100, height - 100, font, paint) if author
      return unless site_name

      site_width, = font.measure_text(site_name)
      canvas.draw_text(site_name, width - 100 - site_width, height - 100, font, paint)
    end

    def wrap_text(text, font, max_width)
      units = text.match?(/\s/) ? text.split : text.scan(/\X/)
      separator = text.match?(/\s/) ? ' ' : ''
      lines = []
      current = ''
      units.each do |unit|
        candidate = current.empty? ? unit : [current, unit].join(separator)
        if current.empty? || font.measure_text(candidate).first <= max_width
          current = candidate
        else
          lines << current
          current = unit
        end
      end
      lines << current unless current.empty?
      lines
    end
  end
end
