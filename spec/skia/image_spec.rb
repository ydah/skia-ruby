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

  describe '#color_type/#alpha_type' do
    it 'returns the image format info' do
      expect(image.color_type).to eq(:rgba_8888).or eq(:bgra_8888)
      expect(%i[premul opaque unpremul unknown]).to include(image.alpha_type)
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

    it 'rejects formats without a native encoder' do
      expect { image.save('animation.gif') }.to raise_error(Skia::UnsupportedOperationError, /png, jpeg, and webp/)
    ensure
      File.delete('animation.gif') if File.exist?('animation.gif')
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

  describe '#subset' do
    it 'creates a subset image' do
      subset = image.subset(Skia::IRect.from_xywh(10, 10, 30, 40))

      expect(subset).to be_a(described_class)
      expect(subset.width).to eq(30)
      expect(subset.height).to eq(40)
    end
  end

  describe '#make_shader' do
    it 'creates an image shader' do
      shader = image.make_shader(tile_x: :repeat, tile_y: :mirror)
      expect(shader).to be_a(Skia::Shader)
    end
  end

  describe '#resize and #scale' do
    it 'resizes an image with sampling options' do
      surface.canvas.clear(Skia::Color::RED)
      resized = image.resize(25, 40, sampling: Skia::SamplingOptions.cubic)

      expect(resized.width).to eq(25)
      expect(resized.height).to eq(40)
      expect(resized.read_pixels(width: 1, height: 1)).to eq("\xFF\x00\x00\xFF".b)
    end

    it 'scales proportionally' do
      scaled = image.scale(0.5)

      expect([scaled.width, scaled.height]).to eq([50, 50])
    end

    it 'rejects invalid dimensions and factors' do
      expect { image.resize(0, 10) }.to raise_error(ArgumentError)
      expect { image.scale(-1) }.to raise_error(ArgumentError)
    end
  end

  describe '#read_pixels' do
    it 'reads pixel bytes from the image' do
      surface.canvas.clear(Skia::Color::BLUE)
      bytes = image.read_pixels(width: 8, height: 6)

      expect(bytes).to be_a(String)
      expect(bytes.bytesize).to eq(8 * 6 * 4)
    end
  end

  describe '#peek_pixels' do
    it 'returns a pixmap view when available' do
      pixmap = image.peek_pixels
      expect(pixmap).to be_a(Skia::Pixmap)
      expect(pixmap.info.width).to eq(100)
      expect(pixmap.info.height).to eq(100)
    end
  end

  describe '#encoded_data' do
    it 'returns encoded image data' do
      data = image.encoded_data
      expect(data).to be_a(Skia::Data)
      expect(data.size).to be > 0
    end
  end
end
