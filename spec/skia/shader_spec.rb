# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Shader do
  describe '.linear_gradient' do
    it 'creates a linear gradient shader' do
      shader = described_class.linear_gradient(
        Skia::Point.new(0, 0),
        Skia::Point.new(100, 100),
        [Skia::Color::RED, Skia::Color::BLUE]
      )

      expect(shader).to be_a(described_class)
    end

    it 'accepts color positions' do
      shader = described_class.linear_gradient(
        Skia::Point.new(0, 0),
        Skia::Point.new(100, 100),
        [Skia::Color::RED, Skia::Color::GREEN, Skia::Color::BLUE],
        [0.0, 0.5, 1.0]
      )

      expect(shader).to be_a(described_class)
    end

    it 'accepts tile mode' do
      shader = described_class.linear_gradient(
        Skia::Point.new(0, 0),
        Skia::Point.new(100, 100),
        [Skia::Color::RED, Skia::Color::BLUE],
        nil,
        tile_mode: :repeat
      )

      expect(shader).to be_a(described_class)
    end

    it 'can be applied to a paint' do
      shader = described_class.linear_gradient(
        Skia::Point.new(0, 0),
        Skia::Point.new(100, 100),
        [Skia::Color::RED, Skia::Color::BLUE]
      )

      paint = Skia::Paint.new
      paint.shader = shader
      expect(paint.shader).not_to be_nil
    end
  end

  describe '.radial_gradient' do
    it 'creates a radial gradient shader' do
      shader = described_class.radial_gradient(
        Skia::Point.new(50, 50),
        50.0,
        [Skia::Color::WHITE, Skia::Color::BLACK]
      )

      expect(shader).to be_a(described_class)
    end

    it 'accepts color positions' do
      shader = described_class.radial_gradient(
        Skia::Point.new(50, 50),
        50.0,
        [Skia::Color::RED, Skia::Color::YELLOW, Skia::Color::GREEN],
        [0.0, 0.3, 1.0]
      )

      expect(shader).to be_a(described_class)
    end
  end

  describe '.sweep_gradient' do
    it 'creates a sweep gradient shader' do
      shader = described_class.sweep_gradient(
        Skia::Point.new(50, 50),
        [Skia::Color::RED, Skia::Color::GREEN, Skia::Color::BLUE, Skia::Color::RED]
      )

      expect(shader).to be_a(described_class)
    end

    it 'accepts start and end angles' do
      shader = described_class.sweep_gradient(
        Skia::Point.new(50, 50),
        [Skia::Color::RED, Skia::Color::BLUE],
        nil,
        start_angle: 0.0,
        end_angle: 180.0
      )

      expect(shader).to be_a(described_class)
    end
  end

  describe 'integration with drawing' do
    it 'draws with gradient shader' do
      surface = Skia::Surface.make_raster(100, 100)

      shader = described_class.linear_gradient(
        Skia::Point.new(0, 0),
        Skia::Point.new(100, 100),
        [Skia::Color::RED, Skia::Color::BLUE]
      )

      paint = Skia::Paint.new
      paint.shader = shader

      surface.draw do |canvas|
        canvas.draw_rect(Skia::Rect.from_xywh(0, 0, 100, 100), paint)
      end

      expect(surface.snapshot.width).to eq(100)
    end
  end
end
