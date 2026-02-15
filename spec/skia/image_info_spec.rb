# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::ImageInfo do
  describe '#initialize' do
    it 'stores dimensions and formats' do
      info = described_class.new(width: 32, height: 16, color_type: :bgra_8888, alpha_type: :premul)
      expect(info.width).to eq(32)
      expect(info.height).to eq(16)
      expect(info.color_type).to eq(:bgra_8888)
      expect(info.alpha_type).to eq(:premul)
    end

    it 'accepts color_space' do
      cs = Skia::ColorSpace.srgb
      info = described_class.new(width: 10, height: 10, color_space: cs)
      expect(info.color_space).to eq(cs)
    end
  end

  describe '#min_row_bytes' do
    it 'calculates row bytes from width and color type' do
      info = described_class.new(width: 5, height: 2, color_type: :rgba_8888)
      expect(info.min_row_bytes).to eq(20)
    end
  end

  describe '#to_struct/.from_struct' do
    it 'round trips through native struct' do
      info = described_class.new(width: 11, height: 13, color_type: :rgba_8888, alpha_type: :premul)
      struct = info.to_struct
      restored = described_class.from_struct(struct)

      expect(restored.width).to eq(11)
      expect(restored.height).to eq(13)
      expect(restored.color_type).to eq(:rgba_8888)
      expect(restored.alpha_type).to eq(:premul)
    end
  end
end
