# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Pixmap do
  describe '.from_pixels' do
    it 'creates a pixmap from byte buffer' do
      info = Skia::ImageInfo.new(width: 2, height: 2, color_type: :rgba_8888, alpha_type: :premul)
      pixels = "\xFF\x00\x00\xFF" * 4
      pixmap = described_class.from_pixels(info, pixels)

      expect(pixmap).to be_a(described_class)
      expect(pixmap.info.width).to eq(2)
      expect(pixmap.info.height).to eq(2)
      expect(pixmap.row_bytes).to eq(8)
    end
  end

  describe '#read_pixels' do
    it 'reads pixel bytes from an image-backed pixmap' do
      surface = Skia::Surface.make_raster(8, 8)
      surface.canvas.clear(Skia::Color::GREEN)
      pixmap = surface.snapshot.peek_pixels
      data = pixmap.read_pixels(Skia::ImageInfo.new(width: 8, height: 8))

      expect(data.bytesize).to eq(8 * 8 * 4)
    end

    it 'keeps the source image alive' do
      surface = Skia::Surface.make_raster(2, 2)
      image = surface.snapshot
      pixmap = image.peek_pixels

      expect(pixmap.instance_variable_get(:@owner)).to equal(image)
    end
  end

  describe '#color_space=' do
    it 'sets and gets color space' do
      info = Skia::ImageInfo.new(width: 1, height: 1)
      pixmap = described_class.from_pixels(info, "\x00\x00\x00\x00" * 1)
      color_space = Skia::ColorSpace.srgb

      pixmap.color_space = color_space
      expect(pixmap.color_space).to be_a(Skia::ColorSpace)
      expect(pixmap.color_space).to be_srgb
    end
  end
end
