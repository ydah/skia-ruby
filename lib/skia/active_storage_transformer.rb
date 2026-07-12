# frozen_string_literal: true

require 'tempfile'

module Skia
  class ActiveStorageTransformer
    SUPPORTED_TRANSFORMATIONS = %i[resize_to_limit resize_to_fit resize_to_fill resize_and_pad crop rotate].freeze

    attr_reader :transformations

    def initialize(transformations)
      @transformations = transformations.transform_keys(&:to_sym)
      unsupported = @transformations.keys - SUPPORTED_TRANSFORMATIONS
      raise ArgumentError, "unsupported Skia variant transformations: #{unsupported.join(', ')}" unless unsupported.empty?
    end

    def transform(file, format:)
      output = process(file, format: format)
      begin
        yield output
      ensure
        output.close!
      end
    end

    private

    def process(file, format:)
      image = Codec.from_file(file.path).decode_frame
      transformations.each do |name, argument|
        image = send("apply_#{name}", image, argument)
      end

      output = Tempfile.new(['skia-variant-', ".#{format}"])
      output.binmode
      image.save(output.path, format: format.to_sym)
      output.rewind
      output
    rescue StandardError
      output&.close!
      raise
    end

    def apply_resize_to_limit(image, dimensions)
      resize_with_ratio(image, dimensions, enlarge: false)
    end

    def apply_resize_to_fit(image, dimensions)
      resize_with_ratio(image, dimensions, enlarge: true)
    end

    def apply_resize_to_fill(image, dimensions)
      target_width, target_height = dimensions(dimensions)
      factor = [target_width.fdiv(image.width), target_height.fdiv(image.height)].max
      resized = image.resize((image.width * factor).ceil, (image.height * factor).ceil)
      x = [(resized.width - target_width) / 2, 0].max
      y = [(resized.height - target_height) / 2, 0].max
      resized.subset(IRect.from_xywh(x, y, target_width, target_height))
    end

    def apply_resize_and_pad(image, argument)
      values = Array(argument)
      target_width, target_height = dimensions(values.first(2))
      background = color_from(values[2] || Color::TRANSPARENT)
      resized = resize_with_ratio(image, [target_width, target_height], enlarge: true)
      Surface.make_raster(target_width, target_height) do |surface|
        surface.canvas.clear(background)
        x = (target_width - resized.width) / 2.0
        y = (target_height - resized.height) / 2.0
        surface.canvas.draw_image(resized, x, y, sampling: SamplingOptions.linear)
        surface.snapshot
      end
    end

    def apply_crop(image, values)
      x, y, width, height = Array(values).map { |value| Integer(value) }
      raise ArgumentError, 'crop requires [x, y, width, height]' unless [x, y, width, height].all?

      image.subset(IRect.from_xywh(x, y, width, height)) || raise(ArgumentError, 'crop is outside the image bounds')
    end

    def apply_rotate(image, degrees)
      angle = Float(degrees)
      radians = angle * Math::PI / 180.0
      output_width = ((image.width * Math.cos(radians).abs) + (image.height * Math.sin(radians).abs)).round(10).ceil
      output_height = ((image.width * Math.sin(radians).abs) + (image.height * Math.cos(radians).abs)).round(10).ceil
      Surface.make_raster(output_width, output_height) do |surface|
        canvas = surface.canvas
        canvas.translate(output_width / 2.0, output_height / 2.0)
        canvas.rotate(angle)
        canvas.draw_image(image, -image.width / 2.0, -image.height / 2.0, sampling: SamplingOptions.linear)
        surface.snapshot
      end
    end

    def resize_with_ratio(image, values, enlarge:)
      max_width, max_height = dimensions(values)
      factors = [max_width.fdiv(image.width), max_height.fdiv(image.height)]
      factors << 1.0 unless enlarge
      factor = factors.min
      image.resize([(image.width * factor).round, 1].max, [(image.height * factor).round, 1].max)
    end

    def dimensions(values)
      width, height = Array(values).map { |value| Integer(value) }
      raise ArgumentError, 'dimensions must contain two positive integers' unless width&.positive? && height&.positive?

      [width, height]
    end

    def color_from(value)
      return value if value.is_a?(Color)
      return Color.from_hex(value) if value.is_a?(String)

      Color.new(Integer(value))
    end
  end
end
