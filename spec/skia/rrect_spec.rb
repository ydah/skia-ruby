# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::RRect do
  describe '.from_rect_xy' do
    it 'creates a rounded rectangle with uniform corner radii' do
      rect = Skia::Rect.from_xywh(10, 20, 100, 60)
      rrect = described_class.from_rect_xy(rect, 8)

      expect(rrect.width).to eq(100.0)
      expect(rrect.height).to eq(60.0)
      expect(rrect.valid?).to be true
      expect(rrect.corner_radius(:upper_left)).to eq(Skia::Point.new(8, 8))
    end
  end

  describe '.from_rect_radii' do
    it 'accepts per-corner radii' do
      rect = Skia::Rect.from_xywh(0, 0, 40, 20)
      radii = [[1, 2], [3, 4], [5, 6], [7, 8]]
      rrect = described_class.from_rect_radii(rect, radii)

      expect(rrect.corner_radius(:upper_right)).to eq(Skia::Point.new(3, 4))
      expect(rrect.corner_radius(:lower_left)).to eq(Skia::Point.new(7, 8))
    end
  end

  describe '#contains_rect?' do
    it 'returns true for enclosed rectangles' do
      rect = Skia::Rect.from_xywh(0, 0, 100, 100)
      rrect = described_class.from_rect_xy(rect, 10)

      expect(rrect.contains_rect?(Skia::Rect.from_xywh(10, 10, 20, 20))).to be true
    end
  end
end
