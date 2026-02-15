# frozen_string_literal: true

module Skia
  class Base
    attr_reader :ptr

    def initialize(ptr, release_method = nil)
      raise NullPointerError, 'Pointer cannot be nil' if ptr.nil? || ptr.null?

      @ptr = ptr
      @release_method = release_method
      setup_release if @release_method
    end

    def to_ptr
      @ptr
    end

    def null?
      @ptr.nil? || @ptr.null?
    end

    def self.release_callback(release_method, ptr)
      proc { Native.send(release_method, ptr) unless ptr.null? }
    end

    protected

    def setup_release
      ObjectSpace.define_finalizer(self, self.class.release_callback(@release_method, @ptr))
    end

    def release!
      return unless @release_method && @ptr && !@ptr.null?

      Native.send(@release_method, @ptr)
      @ptr = nil
    end
  end
end
