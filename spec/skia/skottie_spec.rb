# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe Skia::Skottie do
  let(:sample_json) do
    <<~JSON
      {
        "v": "5.5.7",
        "fr": 30,
        "ip": 0,
        "op": 60,
        "w": 128,
        "h": 128,
        "nm": "sample",
        "ddd": 0,
        "assets": [],
        "layers": []
      }
    JSON
  end

  describe '.available?' do
    it 'returns false when required native symbols are missing' do
      allow(Skia::Native).to receive(:function_available?).and_call_original
      allow(Skia::Native).to receive(:function_available?).with(:skottie_animation_make_from_string).and_return(false)

      expect(described_class.available?).to be(false)
      expect(described_class.missing_symbols).to include(:skottie_animation_make_from_string)
    end
  end

  describe Skia::Skottie::Animation do
    it 'raises UnsupportedOperationError when skottie symbols are unavailable' do
      allow(Skia::Native).to receive(:function_available?).and_call_original
      allow(Skia::Native).to receive(:function_available?).with(:skottie_animation_make_from_string).and_return(false)

      expect { described_class.make_from_json(sample_json) }.to raise_error(Skia::UnsupportedOperationError)
    end

    it 'loads JSON and renders one frame' do
      animation = described_class.make_from_json(sample_json)
      width, height = animation.size
      expect(width).to be > 0
      expect(height).to be > 0

      surface = Skia::Surface.make_raster(128, 128)
      surface.draw do |canvas|
        canvas.clear(Skia::Color::WHITE)
        animation.render_frame(canvas, frame: animation.in_point, rect: Skia::Rect.from_wh(128, 128))
      end

      bytes = surface.read_pixels(width: 4, height: 4)
      expect(animation.fps).to be > 0
      expect(animation.duration).to be > 0
      expect(bytes.bytesize).to eq(4 * 4 * 4)
    end

    it 'raises on invalid JSON' do
      expect { described_class.make_from_json('{not json}') }.to raise_error(Skia::Error)
    end
  end

  describe Skia::Skottie::ResourceProvider do
    it 'loads external files and can add caching' do
      Dir.mktmpdir do |directory|
        File.binwrite(File.join(directory, 'asset.bin'), 'resource')
        provider = described_class.file(directory)

        expect(provider.load('asset.bin').to_s).to eq('resource')
        expect(provider.cached).to be_a(described_class)
      end
    end

    it 'creates a data URI provider with fallback' do
      fallback = described_class.file(Dir.tmpdir)

      expect(described_class.data_uri(fallback: fallback)).to be_a(described_class)
    end
  end

  describe Skia::Skottie::AnimationBuilder do
    it 'builds animations with font and resource providers' do
      builder = described_class.new(flags: [:prefer_embedded_fonts])
      builder.font_manager = Skia::FontManager.default
      builder.resource_provider = Skia::Skottie::ResourceProvider.data_uri

      expect(builder.build_json(sample_json)).to be_a(Skia::Skottie::Animation)
    end
  end
end
