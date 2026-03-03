# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Textlayout do
  describe '.available?' do
    it 'returns false when required native symbols are missing' do
      allow(Skia::Native).to receive(:function_available?).and_call_original
      allow(Skia::Native).to receive(:function_available?).with(:sk_paragraph_builder_new).and_return(false)

      expect(described_class.available?).to be(false)
      expect(described_class.missing_symbols).to include(:sk_paragraph_builder_new)
    end
  end

  describe Skia::Textlayout::Shaper do
    let(:font) { Skia::Font.new(nil, 18) }

    it 'raises UnsupportedOperationError when native shaper symbols are unavailable' do
      allow(Skia::Native).to receive(:function_available?).and_call_original
      allow(Skia::Native).to receive(:function_available?).with(:sk_shaper_new).and_return(false)

      expect { described_class.shape('hello', font) }.to raise_error(Skia::UnsupportedOperationError)
    end

    it 'returns shaped glyphs when textlayout is available' do
      allow(Skia::Textlayout).to receive(:ensure_available!).and_return(true)

      shaped = described_class.shape('hello', font)
      expect(shaped).to be_a(Skia::Textlayout::ShapedText)
      expect(shaped.glyphs).not_to be_empty
      expect(shaped.positions.length).to eq(shaped.glyphs.length)
    end
  end

  describe Skia::Textlayout::Paragraph do
    let(:font) { Skia::Font.new(nil, 20) }
    let(:paint) do
      p = Skia::Paint.new
      p.color = Skia::Color::BLACK
      p
    end

    it 'raises UnsupportedOperationError when native paragraph symbols are unavailable' do
      allow(Skia::Native).to receive(:function_available?).and_call_original
      allow(Skia::Native).to receive(:function_available?).with(:sk_paragraph_layout).and_return(false)

      paragraph = described_class.new('hello paragraph', font: font, paint: paint)
      expect { paragraph.layout(120) }.to raise_error(Skia::UnsupportedOperationError)
    end

    it 'supports shaping + paragraph flow when textlayout is available' do
      allow(Skia::Textlayout).to receive(:ensure_available!).and_return(true)

      shaped = Skia::Textlayout::Shaper.shape('hello paragraph', font)
      paragraph = described_class.new('hello paragraph from skia textlayout', font: font, paint: paint)
      paragraph.layout(150)

      surface = Skia::Surface.make_raster(240, 120)
      surface.draw do |canvas|
        canvas.clear(Skia::Color::WHITE)
        paragraph.draw(canvas, 10, 24)
      end

      bytes = surface.read_pixels(width: 4, height: 4)
      expect(shaped.glyphs.length).to be > 0
      expect(paragraph.lines.length).to be >= 1
      expect(bytes.bytesize).to eq(4 * 4 * 4)
    end
  end
end
