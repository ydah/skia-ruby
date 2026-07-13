# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Document do
  describe '.create_pdf' do
    it 'raises UnsupportedOperationError when metadata native API is unavailable' do
      path = 'test_document_with_meta.pdf'

      allow(Skia::Native).to receive(:function_available?).and_call_original
      allow(Skia::Native).to receive(:function_available?)
        .with(:sk_document_create_pdf_from_stream_with_metadata)
        .and_return(false)

      expect do
        described_class.create_pdf(path, metadata: { title: 'Skia Test' }) do |doc|
          doc.begin_page(100, 100) { |canvas| canvas.clear(Skia::Color::WHITE) }
        end
      end.to raise_error(Skia::UnsupportedOperationError)
    ensure
      File.delete(path) if File.exist?(path)
    end

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

    it 'accepts metadata options' do
      path = 'test_document_with_meta.pdf'

      begin
        described_class.create_pdf(path, metadata: {
                                     title: 'Skia Test',
                                     author: 'RSpec',
                                     raster_dpi: 144.0,
                                     pdfa: false,
                                     encoding_quality: 90,
                                     creation: Time.now
                                   }) do |doc|
          doc.begin_page(100, 100) { |canvas| canvas.clear(Skia::Color::WHITE) }
        end

        expect(File.exist?(path)).to be true
        expect(File.size(path)).to be > 0
      ensure
        File.delete(path) if File.exist?(path)
      end
    end
  end

  describe '.create_pdf_stream' do
    it 'creates a PDF in memory and returns Data' do
      doc = described_class.create_pdf_stream(metadata: { title: 'In-Memory PDF' })
      doc.begin_page(120, 80) do |canvas|
        canvas.clear(Skia::Color::WHITE)
      end

      data = doc.to_data
      expect(data).to be_a(Skia::Data)
      expect(data.to_s).to start_with('%PDF')
    end
  end

  describe 'XPS output' do
    describe '.xps_available?' do
      let(:stream) { FFI::Pointer.new(1) }
      let(:document) { FFI::Pointer.new(2) }

      before do
        allow(Gem).to receive(:win_platform?).and_return(true)
        allow(Skia::Native).to receive(:function_available?)
          .with(:sk_document_create_xps_from_stream)
          .and_return(true)
        allow(Skia::Native).to receive(:sk_dynamicmemorywstream_new).and_return(stream)
      end

      it 'reports XPS support when the native document can be created' do
        allow(Skia::Native).to receive(:sk_document_create_xps_from_stream).and_return(document)

        expect(Skia::Native).to receive(:sk_document_abort).with(document)
        expect(Skia::Native).to receive(:sk_document_unref).with(document)
        expect(Skia::Native).to receive(:sk_dynamicmemorywstream_destroy).with(stream)

        expect(described_class.xps_available?).to be(true)
      end

      it 'reports no XPS support when the native document cannot be created' do
        allow(Skia::Native).to receive(:sk_document_create_xps_from_stream).and_return(FFI::Pointer::NULL)

        expect(Skia::Native).not_to receive(:sk_document_abort)
        expect(Skia::Native).not_to receive(:sk_document_unref)
        expect(Skia::Native).to receive(:sk_dynamicmemorywstream_destroy).with(stream)

        expect(described_class.xps_available?).to be(false)
      end
    end

    it 'creates a multi-page XPS document in memory' do
      skip 'XPS output is supported only by Windows libSkiaSharp builds' unless described_class.xps_available?

      doc = described_class.create_xps_stream(dpi: 144)
      2.times do
        doc.page(120, 80) { |canvas| canvas.clear(Skia::Color::WHITE) }
      end

      data = doc.to_data
      expect(data.to_s).to start_with('PK')
      expect(data.size).to be > 100
    end

    it 'reports native builds without XPS support' do
      allow(described_class).to receive(:xps_available?).and_return(false)

      expect { described_class.create_xps_stream }.to raise_error(Skia::UnsupportedOperationError, /XPS/)
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

    it 'accepts content_rect keyword' do
      path = 'test_document_page_rect.pdf'

      begin
        described_class.create_pdf(path) do |doc|
          doc.begin_page(200, 200, content_rect: Skia::Rect.from_xywh(10, 10, 180, 180)) do |canvas|
            canvas.clear(Skia::Color::WHITE)
          end
        end

        expect(File.size(path)).to be > 0
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
