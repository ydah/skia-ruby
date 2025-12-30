# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Canvas do
  let(:surface) { Skia::Surface.make_raster(640, 480) }
  subject(:canvas) { surface.canvas }

  describe '#clear' do
    it 'clears the canvas with a color' do
      result = canvas.clear(Skia::Color::RED)
      expect(result).to eq(canvas)
    end

    it 'defaults to transparent' do
      result = canvas.clear
      expect(result).to eq(canvas)
    end
  end

  describe '#save and #restore' do
    it 'saves and restores state' do
      initial_count = canvas.save_count
      canvas.save
      expect(canvas.save_count).to eq(initial_count + 1)
      canvas.restore
      expect(canvas.save_count).to eq(initial_count)
    end
  end

  describe '#restore_to_count' do
    it 'restores to a specific save count' do
      count = canvas.save
      canvas.save
      canvas.save
      canvas.restore_to_count(count)
      expect(canvas.save_count).to eq(count)
    end
  end

  describe '#with_save' do
    it 'automatically restores after block' do
      initial_count = canvas.save_count
      canvas.with_save do |c|
        expect(c.save_count).to eq(initial_count + 1)
      end
      expect(canvas.save_count).to eq(initial_count)
    end

    it 'restores even on exception' do
      initial_count = canvas.save_count
      expect do
        canvas.with_save { raise 'test error' }
      end.to raise_error('test error')
      expect(canvas.save_count).to eq(initial_count)
    end
  end

  describe '#translate' do
    it 'translates the canvas' do
      result = canvas.translate(100, 50)
      expect(result).to eq(canvas)
    end
  end

  describe '#scale' do
    it 'scales the canvas' do
      result = canvas.scale(2.0, 2.0)
      expect(result).to eq(canvas)
    end

    it 'accepts single value for uniform scale' do
      result = canvas.scale(2.0)
      expect(result).to eq(canvas)
    end
  end

  describe '#rotate' do
    it 'rotates the canvas' do
      result = canvas.rotate(45)
      expect(result).to eq(canvas)
    end

    it 'rotates around a point' do
      result = canvas.rotate(45, 100, 100)
      expect(result).to eq(canvas)
    end
  end

  describe '#skew' do
    it 'skews the canvas' do
      result = canvas.skew(0.5, 0.0)
      expect(result).to eq(canvas)
    end
  end

  describe '#matrix' do
    it 'gets the current matrix' do
      matrix = canvas.matrix
      expect(matrix).to be_a(Skia::Matrix)
    end

    it 'sets the matrix' do
      new_matrix = Skia::Matrix.translate(100, 100)
      canvas.matrix = new_matrix
      current = canvas.matrix
      expect(current.trans_x).to eq(100.0)
      expect(current.trans_y).to eq(100.0)
    end
  end

  describe '#clip_rect' do
    it 'clips to a rectangle' do
      rect = Skia::Rect.from_xywh(0, 0, 100, 100)
      result = canvas.clip_rect(rect)
      expect(result).to eq(canvas)
    end
  end

  describe '#clip_path' do
    it 'clips to a path' do
      path = Skia::Path.new
      path.add_circle(100, 100, 50)
      result = canvas.clip_path(path)
      expect(result).to eq(canvas)
    end
  end

  describe '#draw_rect' do
    it 'draws a rectangle' do
      rect = Skia::Rect.from_xywh(10, 10, 100, 100)
      paint = Skia::Paint.new
      result = canvas.draw_rect(rect, paint)
      expect(result).to eq(canvas)
    end
  end

  describe '#draw_circle' do
    it 'draws a circle' do
      paint = Skia::Paint.new
      result = canvas.draw_circle(100, 100, 50, paint)
      expect(result).to eq(canvas)
    end
  end

  describe '#draw_oval' do
    it 'draws an oval' do
      rect = Skia::Rect.from_xywh(10, 10, 200, 100)
      paint = Skia::Paint.new
      result = canvas.draw_oval(rect, paint)
      expect(result).to eq(canvas)
    end
  end

  describe '#draw_line' do
    it 'draws a line' do
      paint = Skia::Paint.new
      result = canvas.draw_line(0, 0, 100, 100, paint)
      expect(result).to eq(canvas)
    end
  end

  describe '#draw_path' do
    it 'draws a path' do
      path = Skia::Path.build do
        move_to 0, 0
        line_to 100, 100
        line_to 0, 100
        close
      end
      paint = Skia::Paint.new
      result = canvas.draw_path(path, paint)
      expect(result).to eq(canvas)
    end
  end

  describe '#draw_paint' do
    it 'fills with paint' do
      paint = Skia::Paint.new
      paint.color = Skia::Color::RED
      result = canvas.draw_paint(paint)
      expect(result).to eq(canvas)
    end
  end

  describe '#draw_color' do
    it 'fills with color' do
      result = canvas.draw_color(Skia::Color::BLUE)
      expect(result).to eq(canvas)
    end
  end

  describe '#draw_text' do
    it 'draws text' do
      font = Skia::Font.new(nil, 24.0)
      paint = Skia::Paint.new
      result = canvas.draw_text('Hello', 50, 50, font, paint)
      expect(result).to eq(canvas)
    end
  end
end
