# frozen_string_literal: true

require 'spec_helper'
require 'weakref'

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

    it 'accepts image_info with color space' do
      info = Skia::ImageInfo.new(
        width: 32,
        height: 24,
        color_type: :rgba_8888,
        alpha_type: :premul,
        color_space: Skia::ColorSpace.srgb
      )
      custom_surface = described_class.make_raster(image_info: info)
      expect(custom_surface.width).to eq(32)
      expect(custom_surface.height).to eq(24)
    end

    it 'closes the surface after a block' do
      yielded_surface = nil
      result = described_class.make_raster(8, 8) do |block_surface|
        yielded_surface = block_surface
        :rendered
      end

      expect(result).to eq(:rendered)
      expect(yielded_surface).to be_closed
    end

    it 'closes the surface when a block raises' do
      yielded_surface = nil

      expect do
        described_class.make_raster(8, 8) do |block_surface|
          yielded_surface = block_surface
          raise 'render failed'
        end
      end.to raise_error('render failed')
      expect(yielded_surface).to be_closed
    end
  end

  describe '.make_null' do
    it 'creates a null surface' do
      null_surface = described_class.make_null(128, 64)
      expect(null_surface).to be_a(described_class)
      expect(null_surface.width).to eq(128)
      expect(null_surface.height).to eq(64)
    end
  end

  describe '.make_raster_direct' do
    it 'keeps an FFI pixel buffer alive' do
      pixels = FFI::MemoryPointer.new(:uint8, 16)
      direct_surface = described_class.make_raster_direct(2, 2, pixels: pixels, row_bytes: 8)

      expect(direct_surface.instance_variable_get(:@pixel_storage)).to equal(pixels)
    end
  end

  describe '.make_render_target' do
    it 'raises UnsupportedOperationError when native API is unavailable' do
      allow(Skia::Native).to receive(:function_available?).and_call_original
      allow(Skia::Native).to receive(:function_available?).with(:sk_surface_new_render_target).and_return(false)

      expect do
        described_class.make_render_target(context: FFI::Pointer::NULL, width: 64, height: 64)
      end.to raise_error(Skia::UnsupportedOperationError)
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

    it 'keeps its surface alive' do
      build_canvas = lambda do
        owned_surface = described_class.make_raster(8, 8)
        [WeakRef.new(owned_surface), owned_surface.canvas]
      end
      weak_surface, canvas = build_canvas.call
      GC.start

      expect(weak_surface).to be_weakref_alive
      expect(canvas).not_to be_closed
    end

    it 'cannot be used after its surface is closed' do
      canvas = surface.canvas
      surface.close

      expect { canvas.clear }.to raise_error(Skia::ClosedError)
    end
  end

  describe '#close' do
    it 'is idempotent' do
      surface.close

      expect { surface.close }.not_to raise_error
      expect(surface).to be_closed
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

  describe '#read_pixels' do
    it 'reads pixel bytes from the surface' do
      surface.canvas.clear(Skia::Color::BLUE)
      bytes = surface.read_pixels(width: 16, height: 8)
      expect(bytes.bytesize).to eq(16 * 8 * 4)
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
