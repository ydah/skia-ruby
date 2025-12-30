# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Color do
  describe '.new' do
    it 'creates from integer value' do
      color = described_class.new(0xFFFF0000)
      expect(color.value).to eq(0xFFFF0000)
    end

    it 'creates from RGB values' do
      color = described_class.new(255, 128, 64)
      expect(color.red).to eq(255)
      expect(color.green).to eq(128)
      expect(color.blue).to eq(64)
      expect(color.alpha).to eq(255)
    end

    it 'creates from RGBA values' do
      color = described_class.new(255, 128, 64, 200)
      expect(color.alpha).to eq(200)
    end
  end

  describe '.rgb' do
    it 'creates opaque color' do
      color = described_class.rgb(100, 150, 200)
      expect(color.red).to eq(100)
      expect(color.green).to eq(150)
      expect(color.blue).to eq(200)
      expect(color.alpha).to eq(255)
    end
  end

  describe '.argb' do
    it 'creates color with alpha first' do
      color = described_class.argb(128, 255, 0, 0)
      expect(color.alpha).to eq(128)
      expect(color.red).to eq(255)
    end
  end

  describe '.from_hex' do
    it 'parses 6-digit hex' do
      color = described_class.from_hex('#FF8040')
      expect(color.red).to eq(255)
      expect(color.green).to eq(128)
      expect(color.blue).to eq(64)
    end

    it 'parses 8-digit hex' do
      color = described_class.from_hex('#80FF8040')
      expect(color.alpha).to eq(128)
    end
  end

  describe '#with_alpha' do
    it 'returns new color with different alpha' do
      color = described_class::RED.with_alpha(128)
      expect(color.alpha).to eq(128)
      expect(color.red).to eq(255)
    end
  end

  describe 'constants' do
    it 'has predefined colors' do
      expect(described_class::BLACK.to_i).to eq(0xFF000000)
      expect(described_class::WHITE.to_i).to eq(0xFFFFFFFF)
      expect(described_class::RED.to_i).to eq(0xFFFF0000)
      expect(described_class::GREEN.to_i).to eq(0xFF00FF00)
      expect(described_class::BLUE.to_i).to eq(0xFF0000FF)
    end
  end
end
