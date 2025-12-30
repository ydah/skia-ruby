# frozen_string_literal: true

module Skia
  class Document < Base
    def initialize(ptr, stream)
      super(ptr, :sk_document_unref)
      @stream = stream
      @closed = false
    end

    def self.create_pdf(path)
      stream = Native.sk_filewstream_new(path)
      raise Error, "Failed to create file stream for: #{path}" if stream.nil? || stream.null?

      ptr = Native.sk_document_create_pdf_from_stream(stream)
      if ptr.nil? || ptr.null?
        Native.sk_filewstream_destroy(stream)
        raise Error, 'Failed to create PDF document'
      end

      doc = new(ptr, stream)

      if block_given?
        begin
          yield doc
        ensure
          doc.close
        end
      else
        doc
      end
    end

    def begin_page(width, height, content_rect = nil)
      content_ptr = content_rect&.to_struct
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

    def end_page
      Native.sk_document_end_page(@ptr)
    end

    def close
      return if @closed

      Native.sk_document_close(@ptr)
      Native.sk_filewstream_destroy(@stream) if @stream
      @closed = true
    end

    def abort
      return if @closed

      Native.sk_document_abort(@ptr)
      Native.sk_filewstream_destroy(@stream) if @stream
      @closed = true
    end

    def closed?
      @closed
    end
  end
end
