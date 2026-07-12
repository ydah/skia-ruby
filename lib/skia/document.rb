# frozen_string_literal: true

module Skia
  class Document < Base
    def initialize(ptr, stream, stream_kind:, metadata_refs: [])
      super(ptr, :sk_document_unref)
      @stream = stream
      @stream_kind = stream_kind
      @metadata_refs = metadata_refs
      @closed = false
      @data = nil
    end

    def self.create_pdf(path, metadata: nil, &)
      stream = Native.sk_filewstream_new(path)
      raise Error, "Failed to create file stream for: #{path}" if stream.nil? || stream.null?

      ptr, metadata_refs = create_pdf_document(stream, metadata)
      raise Error, 'Failed to create PDF document' if ptr.nil? || ptr.null?

      doc = new(ptr, stream, stream_kind: :file, metadata_refs: metadata_refs)
      stream = nil # ownership moved to Document instance
      with_optional_block(doc, &)
    rescue StandardError
      Native.sk_filewstream_destroy(stream) if stream && !stream.null?
      raise
    end

    def self.create_pdf_stream(metadata: nil, &)
      stream = Native.sk_dynamicmemorywstream_new
      raise Error, 'Failed to create memory stream' if stream.nil? || stream.null?

      ptr, metadata_refs = create_pdf_document(stream, metadata)
      raise Error, 'Failed to create PDF document' if ptr.nil? || ptr.null?

      doc = new(ptr, stream, stream_kind: :memory, metadata_refs: metadata_refs)
      stream = nil # ownership moved to Document instance
      with_optional_block(doc, &)
    rescue StandardError
      Native.sk_dynamicmemorywstream_destroy(stream) if stream && !stream.null?
      raise
    end

    def begin_page(width, height, rect = nil, content_rect: nil)
      page_rect = content_rect || rect
      content_ptr = page_rect&.to_struct
      canvas_ptr = Native.sk_document_begin_page(@ptr, width.to_f, height.to_f, content_ptr)
      raise Error, 'Failed to begin page' if canvas_ptr.nil? || canvas_ptr.null?

      canvas = Canvas.new(canvas_ptr)

      if block_given?
        begin
          yield canvas
        ensure
          end_page
        end
      else
        canvas
      end
    end

    def page(width, height, content_rect: nil, &)
      begin_page(width, height, content_rect: content_rect, &)
    end

    def end_page
      Native.sk_document_end_page(@ptr)
    end

    def close
      return if @closed

      Native.sk_document_close(@ptr)
      close_stream(finalize_memory_stream: true)
      @closed = true
    end

    def abort
      return if @closed

      Native.sk_document_abort(@ptr)
      close_stream(finalize_memory_stream: false)
      @closed = true
    end

    def to_data
      raise UnsupportedOperationError, 'to_data is available only for memory-backed PDF documents' unless @stream_kind == :memory

      close unless @closed
      @data
    end

    def closed?
      @closed
    end

    private

    def self.with_optional_block(doc, &block)
      if block
        begin
          block.call(doc)
        ensure
          doc.close unless doc.closed?
        end
      else
        doc
      end
    end

    def self.create_pdf_document(stream, metadata)
      return [Native.sk_document_create_pdf_from_stream(stream), []] if metadata.nil?
      unless Native.function_available?(:sk_document_create_pdf_from_stream_with_metadata)
        raise UnsupportedOperationError,
              'PDF metadata is not supported by the current libSkiaSharp build'
      end

      cmetadata, refs = build_pdf_metadata(metadata)
      ptr = Native.sk_document_create_pdf_from_stream_with_metadata(stream, cmetadata)
      [ptr, refs.grep(FFI::Pointer)]
    end

    def self.build_pdf_metadata(metadata)
      raise ArgumentError, 'metadata must be a Hash' unless metadata.is_a?(Hash)

      md = metadata.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
      refs = []
      cmetadata = Native::SKDocumentPdfMetadata.new

      {
        title: :fTitle,
        author: :fAuthor,
        subject: :fSubject,
        keywords: :fKeywords,
        creator: :fCreator,
        producer: :fProducer
      }.each do |key, native_key|
        cmetadata[native_key] = make_sk_string(md[key], refs)
      end

      cmetadata[:fCreation] = make_pdf_datetime(md[:creation], refs)
      cmetadata[:fModified] = make_pdf_datetime(md[:modified], refs)
      cmetadata[:fRasterDPI] = md.fetch(:raster_dpi, 72.0).to_f
      cmetadata[:fPDFA] = md[:pdfa] ? 1 : 0
      cmetadata[:fEncodingQuality] = md.fetch(:encoding_quality, 101).to_i

      refs << cmetadata
      [cmetadata, refs]
    end

    def self.make_sk_string(value, refs)
      return nil if value.nil?

      bytes = value.to_s.b
      src = FFI::MemoryPointer.new(:char, bytes.bytesize)
      src.put_bytes(0, bytes)
      ptr = Native.sk_string_new_with_copy(src, bytes.bytesize)
      raise Error, 'Failed to allocate metadata string' if ptr.nil? || ptr.null?

      refs << ptr
      ptr
    end

    def self.make_pdf_datetime(value, refs)
      return nil if value.nil?

      time = case value
             when Time
               value
             when Hash
               Time.new(
                 value.fetch(:year),
                 value.fetch(:month),
                 value.fetch(:day),
                 value.fetch(:hour, 0),
                 value.fetch(:min, value.fetch(:minute, 0)),
                 value.fetch(:sec, value.fetch(:second, 0)),
                 value[:utc_offset] || '+00:00'
               )
             else
               value.respond_to?(:to_time) ? value.to_time : nil
             end
      raise ArgumentError, "invalid datetime metadata: #{value.inspect}" if time.nil?

      local = time.getlocal
      ctime = Native::SKTimeDateTime.new
      ctime[:fTimeZoneMinutes] = (local.utc_offset / 60).to_i
      ctime[:fYear] = local.year
      ctime[:fMonth] = local.month
      ctime[:fDayOfWeek] = local.wday
      ctime[:fDay] = local.day
      ctime[:fHour] = local.hour
      ctime[:fMinute] = local.min
      ctime[:fSecond] = local.sec

      refs << ctime
      ctime
    end

    def close_stream(finalize_memory_stream:)
      return if @stream.nil? || @stream.null?

      if @stream_kind == :memory
        if finalize_memory_stream
          data_ptr = Native.sk_dynamicmemorywstream_detach_as_data(@stream)
          @data = Data.new(data_ptr) if data_ptr && !data_ptr.null?
        end
        Native.sk_dynamicmemorywstream_destroy(@stream)
      else
        Native.sk_filewstream_destroy(@stream)
      end

      @metadata_refs&.each { |ptr| Native.sk_string_destructor(ptr) unless ptr.null? }

      @stream = nil
      @metadata_refs = nil
    end
  end
end
