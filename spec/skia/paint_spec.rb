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

  describe '#blender' do
    it 'keeps an assigned blender alive' do
      blender = Skia::Blender.arithmetic(0, 1, 1, 0)
      paint.blender = blender

      expect(paint.blender).to equal(blender)
    end

    it 'clears a cached blender when blend mode is assigned' do
      paint.blender = Skia::Blender.mode(:multiply)
      paint.blend_mode = :screen

      expect(paint.blend_mode).to eq(:screen)
      expect(paint.blender).to be_a(Skia::Blender)
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

  describe 'effect setters' do
    it 'supports mask, color, image filters and path effect' do
      mask_filter = Skia::MaskFilter.blur(:normal, sigma: 1.5)
      color_filter = Skia::ColorFilter.mode(Skia::Color::RED, :multiply)
      image_filter = Skia::ImageFilter.blur(1.0, 1.0)
      path_effect = Skia::PathEffect.dash([4, 2], phase: 0.5)
      paint.mask_filter = mask_filter
      paint.color_filter = color_filter
      paint.image_filter = image_filter
      paint.path_effect = path_effect

      expect(paint.mask_filter).to equal(mask_filter)
      expect(paint.color_filter).to equal(color_filter)
      expect(paint.image_filter).to equal(image_filter)
      expect(paint.path_effect).to equal(path_effect)
    end

    it 'keeps a shader alive until it is replaced or reset' do
      shader = Skia::Shader.linear_gradient(
        Skia::Point.new(0, 0),
        Skia::Point.new(10, 10),
        [Skia::Color::BLACK, Skia::Color::WHITE]
      )
      paint.shader = shader

      expect(paint.shader).to equal(shader)

      paint.shader = nil
      expect(paint.shader).to be_nil
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
      expect(paint.shader).to be_nil
    end
  end
end
