# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Bitmap do
  let(:info) { Skia::ImageInfo.new(width: 8, height: 8, color_type: :rgba_8888, alpha_type: :premul) }

  describe '#alloc_pixels' do
    it 'allocates pixel storage' do
      bitmap = described_class.new
      expect(bitmap.alloc_pixels(info)).to be true
      expect(bitmap.allocated?).to be true
      expect(bitmap.byte_count).to be > 0
    end
  end

  describe '#erase and #pixel_color' do
    it 'fills bitmap with a color' do
      bitmap = described_class.new
      bitmap.alloc_pixels(info)
      bitmap.erase(Skia::Color::RED)

      color = bitmap.pixel_color(0, 0)
      expect(color).to be_a(Skia::Color)
      expect(color.to_i).to eq(Skia::Color::RED.to_i)
    end
  end

  describe '#peek_pixels' do
    it 'returns a pixmap view' do
      bitmap = described_class.new
      bitmap.alloc_pixels(info)
      pixmap = bitmap.peek_pixels

      expect(pixmap).to be_a(Skia::Pixmap)
      expect(pixmap.info.width).to eq(8)
      expect(pixmap.info.height).to eq(8)
    end
  end

  describe '#to_image' do
    it 'creates an image from bitmap' do
      bitmap = described_class.new
      bitmap.alloc_pixels(info)
      image = bitmap.to_image

      expect(image).to be_a(Skia::Image)
      expect(image.width).to eq(8)
      expect(image.height).to eq(8)
    end
  end
end
