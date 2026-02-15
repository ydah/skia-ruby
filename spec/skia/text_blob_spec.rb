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
end
