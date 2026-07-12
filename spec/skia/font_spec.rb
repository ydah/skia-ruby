# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Font do
  describe '#initialize' do
    it 'creates a default font' do
      font = described_class.new
      expect(font).to be_a(described_class)
    end

    it 'creates a font with size' do
      font = described_class.new(nil, 24.0)
      expect(font.size).to eq(24.0)
    end

    it 'creates a font with typeface' do
      typeface = Skia::Typeface.default
      font = described_class.new(typeface, 16.0)
      expect(font.size).to eq(16.0)
    end
  end

  describe '#size' do
    it 'returns the font size' do
      font = described_class.new(nil, 36.0)
      expect(font.size).to eq(36.0)
    end

    it 'can be set' do
      font = described_class.new(nil, 12.0)
      font.size = 48.0
      expect(font.size).to eq(48.0)
    end
  end

  describe '#metrics' do
    it 'returns font metrics' do
      font = described_class.new(nil, 24.0)
      metrics = font.metrics

      expect(metrics).to be_a(Skia::FontMetrics)
      expect(metrics.ascent).to be < 0
      expect(metrics.descent).to be > 0
    end
  end

  describe '#measure_text' do
    it 'measures text width and bounds' do
      font = described_class.new(nil, 24.0)
      width, bounds = font.measure_text('Hello')

      expect(width).to be > 0
      expect(bounds).to be_a(Skia::Rect)
      expect(bounds.width).to be > 0
    end

    it 'returns larger width for longer text' do
      font = described_class.new(nil, 24.0)
      width_short, = font.measure_text('Hi')
      width_long, = font.measure_text('Hello World')

      expect(width_long).to be > width_short
    end
  end

  describe '#text_to_glyphs' do
    it 'converts UTF-8 text to glyph IDs' do
      font = described_class.new(nil, 24.0)
      glyphs = font.text_to_glyphs('Hello')

      expect(glyphs).to be_a(Array)
      expect(glyphs).not_to be_empty
      expect(glyphs.all?(Integer)).to be true
    end
  end
end

RSpec.describe Skia::Typeface do
  describe '.default' do
    it 'returns a default typeface' do
      typeface = described_class.default
      expect(typeface).to be_a(described_class)
    end
  end

  describe '.from_name' do
    it 'creates a typeface from font name' do
      typeface = described_class.from_name('Arial')
      # May return nil if font not found, but should not raise
      expect(typeface).to be_nil.or be_a(described_class)
    end

    it 'accepts weight option' do
      typeface = described_class.from_name('Arial', weight: Skia::Typeface::WEIGHT_BOLD)
      expect(typeface).to be_nil.or be_a(described_class)
    end
  end

  describe '#family_name' do
    it 'returns family name when available' do
      typeface = described_class.default
      expect(typeface.family_name).to be_a(String)
      expect(typeface.family_name).not_to be_empty
    end
  end

  describe '#style' do
    it 'returns style details' do
      typeface = described_class.default
      style = typeface.style

      expect(style[:weight]).to be_a(Integer)
      expect(style[:width]).to be_a(Integer)
      expect(%i[upright italic oblique]).to include(style[:slant])
      expect(style[:fixed_pitch]).to eq(true).or eq(false)
      expect(style[:units_per_em]).to be_a(Integer)
    end
  end

  describe '#variation_axes' do
    it 'returns variation axis metadata when available' do
      typeface = described_class.default
      axes = typeface.variation_axes
      expect(axes).to be_a(Array)

      next if axes.empty?

      axis = axes.first
      expect(axis[:tag]).to be_a(String)
      expect(axis[:tag].bytesize).to eq(4)
      expect(axis[:min_value]).to be_a(Float)
      expect(axis[:default_value]).to be_a(Float)
      expect(axis[:max_value]).to be_a(Float)
    end
  end
end

RSpec.describe Skia::FontMetrics do
  let(:font) { Skia::Font.new(nil, 24.0) }
  let(:metrics) { font.metrics }

  it 'has top' do
    expect(metrics.top).to be_a(Float)
  end

  it 'has ascent' do
    expect(metrics.ascent).to be_a(Float)
    expect(metrics.ascent).to be < 0
  end

  it 'has descent' do
    expect(metrics.descent).to be_a(Float)
    expect(metrics.descent).to be > 0
  end

  it 'has bottom' do
    expect(metrics.bottom).to be_a(Float)
  end

  it 'has leading' do
    expect(metrics.leading).to be_a(Float)
  end

  it 'has cap_height' do
    expect(metrics.cap_height).to be_a(Float)
  end

  it 'has x_height' do
    expect(metrics.x_height).to be_a(Float)
  end
end
