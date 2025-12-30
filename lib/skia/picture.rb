# frozen_string_literal: true

module Skia
  class Picture < Base
    def initialize(ptr)
      super(ptr, :sk_picture_unref)
    end

    def self.from_data(data)
      data_obj = data.is_a?(Data) ? data : Data.new(data)
      ptr = Native.sk_picture_deserialize_from_data(data_obj.ptr)
      raise Error, "Failed to deserialize picture" if ptr.nil? || ptr.null?

      new(ptr)
    end

    def self.record(bounds, &block)
      recorder = PictureRecorder.new
      recorder.begin_recording(bounds, &block)
    end

    def unique_id
      Native.sk_picture_get_unique_id(@ptr)
    end

    def cull_rect
      rect_struct = Native::SKRect.new
      Native.sk_picture_get_cull_rect(@ptr, rect_struct)
      Rect.from_struct(rect_struct)
    end

    def playback(canvas)
      Native.sk_picture_playback(@ptr, canvas.ptr)
      self
    end

    def serialize
      data_ptr = Native.sk_picture_serialize_to_data(@ptr)
      raise Error, "Failed to serialize picture" if data_ptr.nil? || data_ptr.null?

      Data.new(data_ptr)
    end

    def approximate_op_count(nested: true)
      Native.sk_picture_approximate_op_count(@ptr, nested)
    end

    def approximate_bytes_used
      Native.sk_picture_approximate_bytes_used(@ptr)
    end

    def save(path)
      data = serialize
      File.binwrite(path, data.to_s)
      self
    end

    def self.load(path)
      data = Data.from_file(path)
      from_data(data)
    end
  end

  class PictureRecorder
    def initialize
      @ptr = Native.sk_picture_recorder_new
      raise Error, "Failed to create picture recorder" if @ptr.nil? || @ptr.null?

      @recording = false
    end

    def ptr
      @ptr
    end

    def begin_recording(bounds)
      bounds_struct = bounds.to_struct
      canvas_ptr = Native.sk_picture_recorder_begin_recording(@ptr, bounds_struct)
      raise Error, "Failed to begin recording" if canvas_ptr.nil? || canvas_ptr.null?

      @recording = true
      canvas = Canvas.new(canvas_ptr)

      if block_given?
        yield canvas
        end_recording
      else
        canvas
      end
    end

    def recording_canvas
      return nil unless @recording

      canvas_ptr = Native.sk_picture_get_recording_canvas(@ptr)
      return nil if canvas_ptr.nil? || canvas_ptr.null?

      Canvas.new(canvas_ptr)
    end

    def end_recording
      return nil unless @recording

      ptr = Native.sk_picture_recorder_end_recording(@ptr)
      @recording = false
      raise Error, "Failed to end recording" if ptr.nil? || ptr.null?

      Picture.new(ptr)
    end

    def recording?
      @recording
    end

    def delete
      Native.sk_picture_recorder_delete(@ptr) if @ptr
      @ptr = nil
    end
  end
end
