# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Path do
  subject(:path) { described_class.new }

  describe '#initialize' do
    it 'creates a new empty path' do
      expect(path).to be_a(described_class)
      expect(path).to be_empty
    end
  end

  describe '.build' do
    it 'creates a path using DSL' do
      path = described_class.build do
        move_to 0, 0
        line_to 100, 100
        close
      end

      expect(path).not_to be_empty
    end
  end

  describe '#move_to' do
    it 'moves to a point' do
      result = path.move_to(10, 20)
      expect(result).to eq(path)
      expect(path).not_to be_empty
    end
  end

  describe '#line_to' do
    it 'adds a line segment' do
      path.move_to(0, 0)
      result = path.line_to(100, 100)
      expect(result).to eq(path)
    end
  end

  describe '#quad_to' do
    it 'adds a quadratic bezier curve' do
      path.move_to(0, 0)
      result = path.quad_to(50, 100, 100, 0)
      expect(result).to eq(path)
    end
  end

  describe '#cubic_to' do
    it 'adds a cubic bezier curve' do
      path.move_to(0, 0)
      result = path.cubic_to(25, 100, 75, 100, 100, 0)
      expect(result).to eq(path)
    end
  end

  describe '#conic_to' do
    it 'adds a conic curve' do
      path.move_to(0, 0)
      result = path.conic_to(50, 100, 100, 0, 0.5)
      expect(result).to eq(path)
    end
  end

  describe '#close' do
    it 'closes the path' do
      path.move_to(0, 0)
      path.line_to(100, 0)
      path.line_to(100, 100)
      result = path.close
      expect(result).to eq(path)
    end
  end

  describe '#add_rect' do
    it 'adds a rectangle to the path' do
      rect = Skia::Rect.from_xywh(0, 0, 100, 100)
      result = path.add_rect(rect)
      expect(result).to eq(path)
      expect(path).not_to be_empty
    end
  end

  describe '#add_oval' do
    it 'adds an oval to the path' do
      rect = Skia::Rect.from_xywh(0, 0, 100, 50)
      result = path.add_oval(rect)
      expect(result).to eq(path)
      expect(path).not_to be_empty
    end
  end

  describe '#add_circle' do
    it 'adds a circle to the path' do
      result = path.add_circle(50, 50, 25)
      expect(result).to eq(path)
      expect(path).not_to be_empty
    end
  end

  describe '#empty?' do
    it 'returns true for new path' do
      expect(path).to be_empty
    end

    it 'returns false after adding content' do
      path.move_to(0, 0)
      expect(path).not_to be_empty
    end
  end

  describe '#bounds' do
    it 'returns the bounding rectangle' do
      path.add_rect(Skia::Rect.from_xywh(10, 20, 100, 50))
      bounds = path.bounds

      expect(bounds).to be_a(Skia::Rect)
      expect(bounds.left).to eq(10.0)
      expect(bounds.top).to eq(20.0)
      expect(bounds.right).to eq(110.0)
      expect(bounds.bottom).to eq(70.0)
    end
  end

  describe '#contains?' do
    it 'returns true for point inside path' do
      path.add_circle(50, 50, 25)
      expect(path.contains?(50, 50)).to be true
    end

    it 'returns false for point outside path' do
      path.add_circle(50, 50, 25)
      expect(path.contains?(0, 0)).to be false
    end
  end

  describe '#fill_type' do
    it 'defaults to winding' do
      expect(path.fill_type).to eq(:winding)
    end

    it 'can be set' do
      path.fill_type = :even_odd
      expect(path.fill_type).to eq(:even_odd)
    end
  end

  describe '#clone' do
    it 'creates a copy of the path' do
      path.add_circle(50, 50, 25)
      cloned = path.clone

      expect(cloned).not_to be_empty
      expect(cloned.bounds.left).to eq(path.bounds.left)
    end
  end

  describe '#reset' do
    it 'clears the path' do
      path.add_circle(50, 50, 25)
      path.reset
      expect(path).to be_empty
    end
  end

  describe '#transform' do
    it 'transforms the path with a matrix' do
      path.add_rect(Skia::Rect.from_xywh(0, 0, 100, 100))
      matrix = Skia::Matrix.translate(50, 50)
      path.transform(matrix)

      bounds = path.bounds
      expect(bounds.left).to eq(50.0)
      expect(bounds.top).to eq(50.0)
    end
  end
end
