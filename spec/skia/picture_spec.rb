# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Picture do
  let(:bounds) { Skia::Rect.from_xywh(0, 0, 100, 100) }

  describe '.record' do
    it 'records drawing commands' do
      picture = described_class.record(bounds) do |canvas|
        paint = Skia::Paint.new
        paint.color = Skia::Color::RED
        canvas.draw_circle(50, 50, 25, paint)
      end

      expect(picture).to be_a(described_class)
    end
  end

  describe '#unique_id' do
    it 'returns a unique identifier' do
      picture = described_class.record(bounds) { |_| }
      expect(picture.unique_id).to be_a(Integer)
      expect(picture.unique_id).to be > 0
    end
  end

  describe '#cull_rect' do
    it 'returns the bounding rectangle' do
      picture = described_class.record(bounds) do |canvas|
        paint = Skia::Paint.new
        canvas.draw_rect(bounds, paint)
      end
      rect = picture.cull_rect

      expect(rect).to be_a(Skia::Rect)
      expect(rect.left).to eq(0.0)
      expect(rect.top).to eq(0.0)
      expect(rect.right).to eq(100.0)
      expect(rect.bottom).to eq(100.0)
    end
  end

  describe '#playback' do
    it 'plays back recorded commands on a canvas' do
      picture = described_class.record(bounds) do |canvas|
        paint = Skia::Paint.new
        paint.color = Skia::Color::RED
        canvas.draw_rect(Skia::Rect.from_xywh(0, 0, 100, 100), paint)
      end

      surface = Skia::Surface.make_raster(200, 200)
      surface.draw do |canvas|
        canvas.clear(Skia::Color::WHITE)
        picture.playback(canvas)
      end

      expect(surface.snapshot.width).to eq(200)
    end
  end

  describe '#serialize and .from_data' do
    it 'serializes to data' do
      picture = described_class.record(bounds) do |canvas|
        paint = Skia::Paint.new
        canvas.draw_circle(50, 50, 25, paint)
      end

      data = picture.serialize
      expect(data).to be_a(Skia::Data)
      expect(data.size).to be > 0
    end

    it 'deserializes from data' do
      picture = described_class.record(bounds) do |canvas|
        paint = Skia::Paint.new
        canvas.draw_circle(50, 50, 25, paint)
      end

      data = picture.serialize
      loaded = described_class.from_data(data)

      expect(loaded).to be_a(described_class)
      expect(loaded.cull_rect.width).to eq(picture.cull_rect.width)
    end
  end

  describe '#approximate_op_count' do
    it 'returns the number of operations' do
      picture = described_class.record(bounds) do |canvas|
        paint = Skia::Paint.new
        canvas.draw_circle(50, 50, 25, paint)
        canvas.draw_rect(Skia::Rect.from_xywh(0, 0, 50, 50), paint)
      end

      expect(picture.approximate_op_count).to be >= 2
    end
  end

  describe '#approximate_bytes_used' do
    it 'returns the memory usage' do
      picture = described_class.record(bounds) do |canvas|
        paint = Skia::Paint.new
        canvas.draw_circle(50, 50, 25, paint)
      end

      expect(picture.approximate_bytes_used).to be > 0
    end
  end

  describe '#save and .load' do
    it 'saves to and loads from a file' do
      path = 'test_picture.skp'

      begin
        picture = described_class.record(bounds) do |canvas|
          paint = Skia::Paint.new
          paint.color = Skia::Color::BLUE
          canvas.draw_circle(50, 50, 25, paint)
        end

        picture.save(path)
        expect(File.exist?(path)).to be true

        loaded = described_class.load(path)
        expect(loaded).to be_a(described_class)
        expect(loaded.cull_rect.width).to eq(100.0)
      ensure
        File.delete(path) if File.exist?(path)
      end
    end
  end
end

RSpec.describe Skia::PictureRecorder do
  describe '#initialize' do
    it 'creates a new recorder' do
      recorder = described_class.new
      expect(recorder).to be_a(described_class)
    end
  end

  describe '#begin_recording' do
    it 'returns a canvas' do
      recorder = described_class.new
      bounds = Skia::Rect.from_xywh(0, 0, 100, 100)
      canvas = recorder.begin_recording(bounds)

      expect(canvas).to be_a(Skia::Canvas)
      recorder.end_recording
    end

    it 'yields a canvas when block given' do
      recorder = described_class.new
      bounds = Skia::Rect.from_xywh(0, 0, 100, 100)

      picture = recorder.begin_recording(bounds) do |canvas|
        expect(canvas).to be_a(Skia::Canvas)
      end

      expect(picture).to be_a(Skia::Picture)
    end
  end

  describe '#recording?' do
    it 'returns false initially' do
      recorder = described_class.new
      expect(recorder).not_to be_recording
    end

    it 'returns true during recording' do
      recorder = described_class.new
      bounds = Skia::Rect.from_xywh(0, 0, 100, 100)
      recorder.begin_recording(bounds)

      expect(recorder).to be_recording
      recorder.end_recording
    end

    it 'returns false after recording' do
      recorder = described_class.new
      bounds = Skia::Rect.from_xywh(0, 0, 100, 100)
      recorder.begin_recording(bounds)
      recorder.end_recording

      expect(recorder).not_to be_recording
    end
  end

  describe '#end_recording' do
    it 'returns a picture' do
      recorder = described_class.new
      bounds = Skia::Rect.from_xywh(0, 0, 100, 100)
      recorder.begin_recording(bounds)
      picture = recorder.end_recording

      expect(picture).to be_a(Skia::Picture)
    end
  end
end
