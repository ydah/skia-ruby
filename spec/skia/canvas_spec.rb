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

    it 'resets the matrix' do
      canvas.translate(10, 20)
      canvas.reset_matrix
      expect(canvas.matrix.identity?).to be true
    end
  end

  describe '#clip_rect' do
    it 'clips to a rectangle' do
      rect = Skia::Rect.from_xywh(0, 0, 100, 100)
      result = canvas.clip_rect(rect)
      expect(result).to eq(canvas)
    end
  end

  describe 'region operations' do
    let(:region) { Skia::Region.new(Skia::IRect.from_xywh(0, 0, 20, 20)) }
    let(:paint) { Skia::Paint.new }

    it 'clips and draws a region' do
      expect(canvas.clip_region(region)).to eq(canvas)
      expect(canvas.draw_region(region, paint)).to eq(canvas)
    end

    it 'quickly rejects rectangles outside the clip' do
      canvas.clip_rect(Skia::Rect.from_xywh(0, 0, 10, 10))

      expect(canvas.quick_reject?(Skia::Rect.from_xywh(20, 20, 5, 5))).to be true
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

  describe '#draw_rrect and #clip_rrect' do
    it 'draws and clips rounded rectangles' do
      paint = Skia::Paint.new
      rrect = Skia::RRect.from_rect_xy(Skia::Rect.from_xywh(10, 10, 120, 60), 12)

      expect(canvas.draw_rrect(rrect, paint)).to eq(canvas)
      expect(canvas.clip_rrect(rrect)).to eq(canvas)
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

  describe '#draw_point and #draw_points' do
    it 'draws points' do
      paint = Skia::Paint.new
      expect(canvas.draw_point(10, 20, paint)).to eq(canvas)

      points = [Skia::Point.new(0, 0), [20, 10], Skia::Point.new(40, 20)]
      expect(canvas.draw_points(points, paint, mode: :polygon)).to eq(canvas)
    end
  end

  describe 'mesh and sprite drawing' do
    let(:paint) do
      Skia::Paint.new.tap { |value| value.color = Skia::Color::RED }
    end

    it 'draws vertices' do
      vertices = Skia::Vertices.make_copy(
        :triangles,
        [[0, 0], [50, 0], [0, 50]],
        colors: [Skia::Color::RED, Skia::Color::GREEN, Skia::Color::BLUE]
      )

      expect(canvas.draw_vertices(vertices, paint)).to eq(canvas)
    end

    it 'draws an image atlas' do
      atlas_surface = Skia::Surface.make_raster(10, 10)
      atlas_surface.canvas.clear(Skia::Color::BLUE)
      atlas = atlas_surface.snapshot

      expect(
        canvas.draw_atlas(
          atlas,
          sprites: [Skia::Rect.from_wh(10, 10)],
          transforms: [Skia::RotationScaleMatrix.translation(5, 5)]
        )
      ).to eq(canvas)
    end

    it 'draws a cubic patch' do
      cubics = [
        [0, 0], [3, 0], [7, 0], [10, 0],
        [10, 3], [10, 7], [10, 10],
        [7, 10], [3, 10], [0, 10],
        [0, 7], [0, 3]
      ]

      expect(canvas.draw_patch(cubics, paint)).to eq(canvas)
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

  describe '#draw_arc' do
    it 'draws an arc' do
      paint = Skia::Paint.new
      oval = Skia::Rect.from_xywh(50, 50, 120, 80)
      expect(canvas.draw_arc(oval, 0, 180, true, paint)).to eq(canvas)
    end
  end

  describe '#draw_picture' do
    it 'draws a picture with an optional matrix' do
      picture = Skia::Picture.record(Skia::Rect.from_xywh(0, 0, 50, 50)) do |c|
        c.draw_circle(25, 25, 20, Skia::Paint.new)
      end

      matrix = Skia::Matrix.translate(5, 5)
      paint = Skia::Paint.new
      expect(canvas.draw_picture(picture, matrix, paint)).to eq(canvas)
    end
  end

  describe '#draw_text_blob' do
    it 'draws a text blob' do
      font = Skia::Font.new(nil, 24.0)
      blob = Skia::TextBlob.from_text('Blob', font)
      paint = Skia::Paint.new

      expect(canvas.draw_text_blob(blob, 20, 60, paint)).to eq(canvas)
    end
  end

  describe '#draw_text_on_path' do
    it 'draws glyphs following the path tangent' do
      path = Skia::Path.new.move_to(5, 50).quad_to(50, 5, 95, 50)
      font = Skia::Font.new(nil, 16)
      paint = Skia::Paint.new

      expect(canvas.draw_text_on_path('Curve', path, font, paint)).to eq(canvas)
    end
  end
end
