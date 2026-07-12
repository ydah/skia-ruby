# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Svg do
  let(:sample_svg) do
    <<~SVG
      <svg width="100" height="100" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
        <path d="M 10 10 L 90 10 L 90 90 L 10 90 Z" fill="#ff0000" />
      </svg>
    SVG
  end

  describe '.available?' do
    it 'returns false when required native symbols are missing' do
      allow(Skia::Native).to receive(:function_available?).and_call_original
      allow(Skia::Native).to receive(:function_available?).with(:sk_path_parse_svg_string).and_return(false)

      expect(described_class.available?).to be(false)
      expect(described_class.missing_symbols).to include(:sk_path_parse_svg_string)
    end
  end

  describe '.parse_path' do
    it 'raises UnsupportedOperationError when parser symbols are unavailable' do
      allow(Skia::Native).to receive(:function_available?).and_call_original
      allow(Skia::Native).to receive(:function_available?).with(:sk_path_parse_svg_string).and_return(false)

      expect { described_class.parse_path('M0 0 L10 10 Z') }.to raise_error(Skia::UnsupportedOperationError)
    end

    it 'parses an SVG path and can round-trip back to path data' do
      path = described_class.parse_path('M 0 0 L 20 0 L 20 20 Z')
      svg_path = described_class.path_to_svg(path)

      expect(path).to be_a(Skia::Path)
      expect(svg_path).to include('M')
    end
  end

  describe '.render' do
    it 'renders drawing commands to SVG data' do
      data = described_class.render(80, 60) do |canvas|
        paint = Skia::Paint.new
        paint.color = Skia::Color::RED
        canvas.draw_circle(40, 30, 20, paint)
      end

      expect(data.to_s).to include('<svg', '<ellipse')
    end

    it 'requires a drawing block' do
      expect { described_class.render(80, 60) }.to raise_error(ArgumentError)
    end
  end

  describe Skia::Svg::Dom do
    it 'loads and draws a simple SVG path' do
      dom = described_class.from_svg(sample_svg)
      expect(dom.width).to eq(100.0)
      expect(dom.height).to eq(100.0)
      expect(dom).not_to be_empty

      surface = Skia::Surface.make_raster(120, 120)
      surface.draw do |canvas|
        canvas.clear(Skia::Color::WHITE)
        dom.draw(canvas, x: 10, y: 10)
      end

      bytes = surface.read_pixels(width: 4, height: 4)
      expect(bytes.bytesize).to eq(4 * 4 * 4)
    end

    it 'raises on invalid SVG input' do
      expect { described_class.from_svg('<svg><path d="M 0 0"') }.to raise_error(Skia::Error)
    end
  end
end
