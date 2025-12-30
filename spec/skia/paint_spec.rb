# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Paint do
  subject(:paint) { described_class.new }

  describe '#initialize' do
    it 'creates a new paint' do
      expect(paint).to be_a(described_class)
      expect(paint.ptr).not_to be_nil
    end
  end

  describe '#color' do
    it 'defaults to black' do
      expect(paint.color.to_i).to eq(Skia::Color::BLACK.to_i)
    end

    it 'can be set with a Color object' do
      paint.color = Skia::Color::RED
      expect(paint.color.to_i).to eq(Skia::Color::RED.to_i)
    end

    it 'can be set with an integer' do
      paint.color = 0xFF00FF00
      expect(paint.color.to_i).to eq(0xFF00FF00)
    end
  end

  describe '#antialias?' do
    it 'defaults to false' do
      expect(paint.antialias?).to be false
    end

    it 'can be set to true' do
      paint.antialias = true
      expect(paint.antialias?).to be true
    end
  end

  describe '#style' do
    it 'defaults to fill' do
      expect(paint.style).to eq(:fill)
    end

    it 'can be set to stroke' do
      paint.style = :stroke
      expect(paint.style).to eq(:stroke)
    end

    it 'can be set to stroke_and_fill' do
      paint.style = :stroke_and_fill
      expect(paint.style).to eq(:stroke_and_fill)
    end
  end

  describe '#stroke_width' do
    it 'defaults to 0' do
      expect(paint.stroke_width).to eq(0.0)
    end

    it 'can be set' do
      paint.stroke_width = 5.0
      expect(paint.stroke_width).to eq(5.0)
    end
  end

  describe '#stroke_cap' do
    it 'defaults to butt' do
      expect(paint.stroke_cap).to eq(:butt)
    end

    it 'can be set to round' do
      paint.stroke_cap = :round
      expect(paint.stroke_cap).to eq(:round)
    end

    it 'can be set to square' do
      paint.stroke_cap = :square
      expect(paint.stroke_cap).to eq(:square)
    end
  end

  describe '#stroke_join' do
    it 'defaults to miter' do
      expect(paint.stroke_join).to eq(:miter)
    end

    it 'can be set to round' do
      paint.stroke_join = :round
      expect(paint.stroke_join).to eq(:round)
    end

    it 'can be set to bevel' do
      paint.stroke_join = :bevel
      expect(paint.stroke_join).to eq(:bevel)
    end
  end

  describe '#stroke_miter' do
    it 'has a default value' do
      expect(paint.stroke_miter).to be > 0
    end

    it 'can be set' do
      paint.stroke_miter = 10.0
      expect(paint.stroke_miter).to eq(10.0)
    end
  end

  describe '#blend_mode' do
    it 'defaults to src_over' do
      expect(paint.blend_mode).to eq(:src_over)
    end

    it 'can be set' do
      paint.blend_mode = :multiply
      expect(paint.blend_mode).to eq(:multiply)
    end
  end

  describe '#clone' do
    it 'creates a copy with the same properties' do
      paint.color = Skia::Color::RED
      paint.style = :stroke
      paint.stroke_width = 3.0

      cloned = paint.clone
      expect(cloned.color).to eq(paint.color)
      expect(cloned.style).to eq(paint.style)
      expect(cloned.stroke_width).to eq(paint.stroke_width)
    end

    it 'creates an independent copy' do
      cloned = paint.clone
      cloned.color = Skia::Color::BLUE
      expect(paint.color).not_to eq(cloned.color)
    end
  end

  describe '#reset' do
    it 'resets all properties to defaults' do
      paint.color = Skia::Color::RED
      paint.style = :stroke
      paint.stroke_width = 5.0

      paint.reset
      expect(paint.color.to_i).to eq(Skia::Color::BLACK.to_i)
      expect(paint.style).to eq(:fill)
      expect(paint.stroke_width).to eq(0.0)
    end
  end
end
