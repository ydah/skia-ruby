# frozen_string_literal: true

module Skia
  module Native
    # Document (PDF)
    attach_function :sk_document_unref, [:sk_document_t], :void
    attach_function :sk_document_create_pdf_from_stream, [:pointer], :sk_document_t
    optional_attach_function :sk_document_create_pdf_from_stream_with_metadata,
                             [:pointer, SKDocumentPdfMetadata.ptr], :sk_document_t
    optional_attach_function :sk_document_create_xps_from_stream, %i[pointer float], :sk_document_t
    attach_function :sk_document_begin_page, [:sk_document_t, :float, :float, SKRect.ptr], :sk_canvas_t
    attach_function :sk_document_end_page, [:sk_document_t], :void
    attach_function :sk_document_close, [:sk_document_t], :void
    attach_function :sk_document_abort, [:sk_document_t], :void

    # FileWStream (for PDF output)
    attach_function :sk_filewstream_new, [:string], :pointer
    attach_function :sk_filewstream_destroy, [:pointer], :void

    # Picture Recorder
    attach_function :sk_picture_recorder_new, [], :sk_picture_recorder_t
    attach_function :sk_picture_recorder_delete, [:sk_picture_recorder_t], :void
    attach_function :sk_picture_recorder_begin_recording, [:sk_picture_recorder_t, SKRect.ptr], :sk_canvas_t
    attach_function :sk_picture_recorder_end_recording, [:sk_picture_recorder_t], :sk_picture_t
    attach_function :sk_picture_get_recording_canvas, [:sk_picture_recorder_t], :sk_canvas_t

    # Picture
    attach_function :sk_picture_ref, [:sk_picture_t], :void
    attach_function :sk_picture_unref, [:sk_picture_t], :void
    attach_function :sk_picture_get_unique_id, [:sk_picture_t], :uint32
    attach_function :sk_picture_get_cull_rect, [:sk_picture_t, SKRect.ptr], :void
    attach_function :sk_picture_playback, %i[sk_picture_t sk_canvas_t], :void
    attach_function :sk_picture_serialize_to_data, [:sk_picture_t], :sk_data_t
    attach_function :sk_picture_deserialize_from_data, [:sk_data_t], :sk_picture_t
    attach_function :sk_picture_approximate_op_count, %i[sk_picture_t bool], :int
    attach_function :sk_picture_approximate_bytes_used, [:sk_picture_t], :size_t
  end
end
