# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::ColorSpace do
  describe '.srgb' do
    it 'creates an sRGB color space' do
      color_space = described_class.srgb
      expect(color_space).to be_a(described_class)
      expect(color_space).to be_srgb
    end
  end

  describe '.srgb_linear' do
    it 'creates a linear sRGB color space' do
      color_space = described_class.srgb_linear
      expect(color_space).to be_a(described_class)
      expect(color_space.linear_gamma?).to be true
    end
  end

  describe '#==' do
    it 'compares by native equality' do
      a = described_class.srgb
      b = described_class.srgb
      c = described_class.srgb_linear

      expect(a == b).to be true
      expect(a == c).to be false
    end
  end
end
