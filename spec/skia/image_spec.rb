# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Image do
  let(:surface) { Skia::Surface.make_raster(100, 100) }
  let(:image) { surface.snapshot }

  describe '#width' do
    it 'returns the image width' do
      expect(image.width).to eq(100)
    end
  end

  describe '#height' do
    it 'returns the image height' do
      expect(image.height).to eq(100)
    end
  end

  describe '#unique_id' do
    it 'returns a unique identifier' do
      expect(image.unique_id).to be_a(Integer)
      expect(image.unique_id).to be > 0
    end
  end

  describe '.from_data' do
    it 'creates an image from encoded data' do
      surface.canvas.clear(Skia::Color::RED)
      encoded = surface.encode(:png)
      loaded = described_class.from_data(encoded)

      expect(loaded).to be_a(described_class)
      expect(loaded.width).to eq(100)
      expect(loaded.height).to eq(100)
    end
  end

  describe '#save' do
    it 'saves to a file with automatic format detection' do
      surface.canvas.clear(Skia::Color::GREEN)
      path = 'test_image.png'

      begin
        image.save(path)
        expect(File.exist?(path)).to be true
      ensure
        File.delete(path) if File.exist?(path)
      end
    end
  end

  describe '#save_png' do
    it 'saves as PNG' do
      surface.canvas.clear(Skia::Color::BLUE)
      path = 'test_image.png'

      begin
        image.save_png(path)
        expect(File.exist?(path)).to be true
        content = File.binread(path)
        expect(content[0..3]).to eq("\x89PNG".b)
      ensure
        File.delete(path) if File.exist?(path)
      end
    end
  end

  describe '#save_jpeg' do
    it 'saves as JPEG' do
      surface.canvas.clear(Skia::Color::RED)
      path = 'test_image.jpg'

      begin
        image.save_jpeg(path)
        expect(File.exist?(path)).to be true
        content = File.binread(path)
        expect(content[0..1]).to eq("\xFF\xD8".b)
      ensure
        File.delete(path) if File.exist?(path)
      end
    end
  end
end
