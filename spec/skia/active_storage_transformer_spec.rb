# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

RSpec.describe Skia::ActiveStorageTransformer do
  def source_file(width: 80, height: 40)
    file = Tempfile.new(['source-', '.png'])
    begin
      Skia::Surface.make_raster(width, height) do |surface|
        surface.canvas.clear(Skia::Color::RED)
        surface.save_png(file.path)
      end
      file.rewind
      yield file
    ensure
      file.close!
    end
  end

  it 'implements the Active Storage transformer contract' do
    source_file do |source|
      transformer = described_class.new(resize_to_limit: [20, 20])

      result = transformer.transform(source, format: :webp) do |output|
        image = Skia::Image.from_file(output.path)
        [image.width, image.height, File.binread(output.path, 4)]
      end

      expect(result.first(2)).to eq([20, 10])
      expect(result.last).to eq('RIFF')
    end
  end

  it 'supports fill, crop, pad, and rotate operations' do
    source_file do |source|
      transformations = { resize_to_fill: [30, 30], crop: [5, 5, 20, 20], resize_and_pad: [32, 24, '#00FF00'], rotate: 90 }
      transformer = described_class.new(transformations)

      dimensions = transformer.transform(source, format: :png) do |output|
        image = Skia::Image.from_file(output.path)
        [image.width, image.height]
      end

      expect(dimensions).to eq([24, 32])
    end
  end

  it 'rejects unsupported operations before processing' do
    expect { described_class.new(blur: 2) }.to raise_error(ArgumentError, /blur/)
  end
end
