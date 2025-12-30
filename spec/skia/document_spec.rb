# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Document do
  describe '.create_pdf' do
    it 'creates a PDF document' do
      path = 'test_document.pdf'

      begin
        described_class.create_pdf(path) do |doc|
          expect(doc).to be_a(described_class)
          # Must create at least one page for a valid PDF
          doc.begin_page(100, 100) do |canvas|
            canvas.clear(Skia::Color::WHITE)
          end
        end

        expect(File.exist?(path)).to be true
        expect(File.size(path)).to be > 0
      ensure
        File.delete(path) if File.exist?(path)
      end
    end

    it 'creates a valid PDF file' do
      path = 'test_document.pdf'

      begin
        described_class.create_pdf(path) do |doc|
          doc.begin_page(612, 792) do |canvas|
            canvas.clear(Skia::Color::WHITE)
          end
        end

        content = File.binread(path)
        expect(content).to start_with('%PDF')
      ensure
        File.delete(path) if File.exist?(path)
      end
    end
  end

  describe '#begin_page' do
    it 'returns a canvas for the page' do
      path = 'test_document.pdf'

      begin
        described_class.create_pdf(path) do |doc|
          doc.begin_page(612, 792) do |canvas|
            expect(canvas).to be_a(Skia::Canvas)
          end
        end
      ensure
        File.delete(path) if File.exist?(path)
      end
    end

    it 'allows drawing on the page' do
      path = 'test_document.pdf'

      begin
        described_class.create_pdf(path) do |doc|
          doc.begin_page(612, 792) do |canvas|
            paint = Skia::Paint.new
            paint.color = Skia::Color::RED
            canvas.draw_rect(Skia::Rect.from_xywh(100, 100, 200, 200), paint)
          end
        end

        expect(File.size(path)).to be > 100
      ensure
        File.delete(path) if File.exist?(path)
      end
    end
  end

  describe '#closed?' do
    it 'returns false before closing' do
      path = 'test_document.pdf'

      begin
        doc = described_class.create_pdf(path)
        expect(doc).not_to be_closed
        doc.close
      ensure
        File.delete(path) if File.exist?(path)
      end
    end

    it 'returns true after closing' do
      path = 'test_document.pdf'

      begin
        doc = described_class.create_pdf(path)
        doc.close
        expect(doc).to be_closed
      ensure
        File.delete(path) if File.exist?(path)
      end
    end
  end

  describe 'multi-page document' do
    it 'creates a document with multiple pages' do
      path = 'test_document.pdf'

      begin
        described_class.create_pdf(path) do |doc|
          3.times do |i|
            doc.begin_page(612, 792) do |canvas|
              canvas.clear(Skia::Color::WHITE)
              font = Skia::Font.new(nil, 24)
              paint = Skia::Paint.new
              canvas.draw_text("Page #{i + 1}", 100, 100, font, paint)
            end
          end
        end

        expect(File.size(path)).to be > 100
      ensure
        File.delete(path) if File.exist?(path)
      end
    end
  end
end
