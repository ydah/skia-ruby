# frozen_string_literal: true

module Skia
  class Base
    def initialize(ptr, release_method = nil, owner: nil)
      raise NullPointerError, 'Pointer cannot be nil' if ptr.nil? || ptr.null?

      @ptr = ptr
      @release_method = release_method
      @owner = owner
      setup_release if @release_method
    end

    def ptr
      raise ClosedError, "#{self.class} has been closed" if closed?

      @ptr
    end

    def to_ptr
      ptr
    end

    def null?
      closed?
    end

    def closed?
      @ptr.nil? || @ptr.null?
    end

    def close
      release!
    end

    def self.release_callback(release_method, ptr)
      proc { Native.send(release_method, ptr) unless ptr.null? }
    end

    protected

    def setup_release
      ObjectSpace.define_finalizer(self, self.class.release_callback(@release_method, @ptr))
    end

    def release!
      return self if closed?

      pointer = @ptr
      @ptr = nil
      @owner = nil
      ObjectSpace.undefine_finalizer(self) if @release_method
      Native.send(@release_method, pointer) if @release_method
      self
    end
  end
end
