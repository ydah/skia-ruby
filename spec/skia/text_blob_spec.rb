# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::TextBlob do
  describe '.from_text' do
    it 'creates a text blob from text and font' do
      font = Skia::Font.new(nil, 24.0)
      blob = described_class.from_text('Hello', font)

      expect(blob).to be_a(described_class)
      expect(blob.unique_id).to be > 0
      expect(blob.bounds).to be_a(Skia::Rect)
    end
  end

  describe '.from_text_on_path' do
    it 'creates rotated glyph runs along a path' do
      font = Skia::Font.new(nil, 18)
      path = Skia::Path.new.move_to(10, 40).cubic_to(50, 0, 100, 80, 150, 40)
      blob = described_class.from_text_on_path('Along a curve', font, path, offset: 4)

      expect(blob).to be_a(described_class)
      expect(blob.unique_id).to be_positive
    end

    it 'returns nil when all glyph origins fall outside the path' do
      font = Skia::Font.new(nil, 18)
      path = Skia::Path.new.move_to(0, 0).line_to(10, 0)

      expect(described_class.from_text_on_path('Text', font, path, offset: 20)).to be_nil
    end
  end
end
