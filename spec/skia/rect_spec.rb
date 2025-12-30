# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Rect do
  describe '.new' do
    it 'creates rect with bounds' do
      rect = described_class.new(10, 20, 110, 120)
      expect(rect.left).to eq(10)
      expect(rect.top).to eq(20)
      expect(rect.right).to eq(110)
      expect(rect.bottom).to eq(120)
    end
  end

  describe '.from_xywh' do
    it 'creates from position and size' do
      rect = described_class.from_xywh(10, 20, 100, 80)
      expect(rect.left).to eq(10)
      expect(rect.top).to eq(20)
      expect(rect.width).to eq(100)
      expect(rect.height).to eq(80)
    end
  end

  describe '.from_wh' do
    it 'creates from origin with size' do
      rect = described_class.from_wh(100, 80)
      expect(rect.left).to eq(0)
      expect(rect.top).to eq(0)
      expect(rect.width).to eq(100)
      expect(rect.height).to eq(80)
    end
  end

  describe '#width and #height' do
    it 'calculates dimensions' do
      rect = described_class.new(10, 20, 110, 100)
      expect(rect.width).to eq(100)
      expect(rect.height).to eq(80)
    end
  end

  describe '#center' do
    it 'returns center point' do
      rect = described_class.new(0, 0, 100, 80)
      expect(rect.center_x).to eq(50)
      expect(rect.center_y).to eq(40)
    end
  end

  describe '#contains?' do
    let(:rect) { described_class.new(0, 0, 100, 100) }

    it 'returns true for point inside' do
      expect(rect.contains?(50, 50)).to be true
    end

    it 'returns false for point outside' do
      expect(rect.contains?(150, 50)).to be false
    end
  end

  describe '#offset' do
    it 'returns moved rect' do
      rect = described_class.new(0, 0, 100, 100)
      moved = rect.offset(10, 20)
      expect(moved.left).to eq(10)
      expect(moved.top).to eq(20)
    end
  end

  describe '#inset' do
    it 'returns shrunk rect' do
      rect = described_class.new(0, 0, 100, 100)
      inset = rect.inset(10, 10)
      expect(inset.width).to eq(80)
      expect(inset.height).to eq(80)
    end
  end
end
