# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Point do
  describe '.new' do
    it 'creates point with coordinates' do
      point = described_class.new(10.5, 20.5)
      expect(point.x).to eq(10.5)
      expect(point.y).to eq(20.5)
    end

    it 'defaults to origin' do
      point = described_class.new
      expect(point.x).to eq(0.0)
      expect(point.y).to eq(0.0)
    end
  end

  describe 'arithmetic' do
    let(:p1) { described_class.new(10, 20) }
    let(:p2) { described_class.new(5, 10) }

    it 'adds points' do
      result = p1 + p2
      expect(result.x).to eq(15)
      expect(result.y).to eq(30)
    end

    it 'subtracts points' do
      result = p1 - p2
      expect(result.x).to eq(5)
      expect(result.y).to eq(10)
    end

    it 'multiplies by scalar' do
      result = p1 * 2
      expect(result.x).to eq(20)
      expect(result.y).to eq(40)
    end
  end

  describe '#length' do
    it 'calculates vector length' do
      point = described_class.new(3, 4)
      expect(point.length).to eq(5.0)
    end
  end

  describe '#normalize' do
    it 'returns unit vector' do
      point = described_class.new(3, 4)
      normalized = point.normalize
      expect(normalized.length).to be_within(0.0001).of(1.0)
    end
  end
end
