# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Surface do
  subject(:surface) { described_class.make_raster(640, 480) }

  describe '.make_raster' do
    it 'creates a raster surface' do
      expect(surface).to be_a(described_class)
    end

    it 'has correct dimensions' do
      expect(surface.width).to eq(640)
      expect(surface.height).to eq(480)
    end

    it 'accepts color_type option' do
      surface = described_class.make_raster(100, 100, color_type: :bgra_8888)
      expect(surface).to be_a(described_class)
    end

    it 'accepts alpha_type option' do
      surface = described_class.make_raster(100, 100, alpha_type: :opaque)
      expect(surface).to be_a(described_class)
    end
  end

  describe '#canvas' do
    it 'returns a canvas' do
      canvas = surface.canvas
      expect(canvas).to be_a(Skia::Canvas)
    end

    it 'returns the same canvas instance' do
      canvas1 = surface.canvas
      canvas2 = surface.canvas
      expect(canvas1.ptr).to eq(canvas2.ptr)
    end
  end

  describe '#snapshot' do
    it 'returns an image' do
      image = surface.snapshot
      expect(image).to be_a(Skia::Image)
    end

    it 'returns an image with correct dimensions' do
      image = surface.snapshot
      expect(image.width).to eq(640)
      expect(image.height).to eq(480)
    end
  end

  describe '#draw' do
    it 'yields a canvas' do
      surface.draw do |canvas|
        expect(canvas).to be_a(Skia::Canvas)
      end
    end

    it 'returns self' do
      result = surface.draw { |_| }
      expect(result).to eq(surface)
    end
  end

  describe '#encode' do
    it 'encodes as PNG by default' do
      surface.canvas.clear(Skia::Color::RED)
      data = surface.encode
      expect(data).to be_a(Skia::Data)
      expect(data.size).to be > 0
    end

    it 'encodes as JPEG' do
      surface.canvas.clear(Skia::Color::RED)
      data = surface.encode(:jpeg)
      expect(data).to be_a(Skia::Data)
      expect(data.size).to be > 0
    end

    it 'encodes as WebP' do
      surface.canvas.clear(Skia::Color::RED)
      data = surface.encode(:webp)
      expect(data).to be_a(Skia::Data)
      expect(data.size).to be > 0
    end
  end

  describe '#save_png' do
    it 'saves to a PNG file' do
      surface.canvas.clear(Skia::Color::RED)
      path = 'test_output.png'

      begin
        surface.save_png(path)
        expect(File.exist?(path)).to be true
        expect(File.size(path)).to be > 0
      ensure
        File.delete(path) if File.exist?(path)
      end
    end
  end

  describe '#save_jpeg' do
    it 'saves to a JPEG file' do
      surface.canvas.clear(Skia::Color::RED)
      path = 'test_output.jpg'

      begin
        surface.save_jpeg(path)
        expect(File.exist?(path)).to be true
        expect(File.size(path)).to be > 0
      ensure
        File.delete(path) if File.exist?(path)
      end
    end
  end
end
