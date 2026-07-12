# frozen_string_literal: true

module Skia
  class Region < Base
    include Enumerable

    def initialize(source = nil)
      super(Native.sk_region_new, :sk_region_delete)

      case source
      when nil then nil
      when IRect then set_rect(source)
      when Region then set_region(source)
      when Path then set_path(source)
      else raise ArgumentError, 'source must be a Skia::IRect, Region, Path, or nil'
      end
    end

    def empty?
      Native.sk_region_is_empty(@ptr)
    end

    def rect?
      Native.sk_region_is_rect(@ptr)
    end

    def complex?
      Native.sk_region_is_complex(@ptr)
    end

    def bounds
      rect = Native::SKIRect.new
      Native.sk_region_get_bounds(@ptr, rect)
      IRect.from_struct(rect)
    end

    def boundary_path
      path = Path.new
      return path if Native.sk_region_get_boundary_path(@ptr, path.ptr)

      path.dispose
      nil
    end

    def contains?(*args)
      case args
      in [Integer => x, Integer => y]
        Native.sk_region_contains_point(@ptr, x, y)
      in [IRect => rect]
        Native.sk_region_contains_rect(@ptr, rect.to_struct)
      in [Region => region]
        Native.sk_region_contains(@ptr, region.ptr)
      else
        raise ArgumentError, 'expected (x, y), Skia::IRect, or Skia::Region'
      end
    end

    def intersects?(other)
      case other
      when IRect then Native.sk_region_intersects_rect(@ptr, other.to_struct)
      when Region then Native.sk_region_intersects(@ptr, other.ptr)
      else raise ArgumentError, 'other must be a Skia::IRect or Region'
      end
    end

    def quick_contains?(rect)
      raise ArgumentError, 'rect must be a Skia::IRect' unless rect.is_a?(IRect)

      Native.sk_region_quick_contains(@ptr, rect.to_struct)
    end

    def quick_reject?(other)
      case other
      when IRect then Native.sk_region_quick_reject_rect(@ptr, other.to_struct)
      when Region then Native.sk_region_quick_reject(@ptr, other.ptr)
      else raise ArgumentError, 'other must be a Skia::IRect or Region'
      end
    end

    def set_empty
      Native.sk_region_set_empty(@ptr)
      self
    end

    def set_rect(rect)
      raise ArgumentError, 'rect must be a Skia::IRect' unless rect.is_a?(IRect)

      Native.sk_region_set_rect(@ptr, rect.to_struct)
      self
    end

    def set_region(region)
      raise ArgumentError, 'region must be a Skia::Region' unless region.is_a?(Region)

      Native.sk_region_set_region(@ptr, region.ptr)
      self
    end

    def set_path(path, clip: nil)
      raise ArgumentError, 'path must be a Skia::Path' unless path.is_a?(Path)
      raise ArgumentError, 'clip must be a Skia::Region or nil' unless clip.nil? || clip.is_a?(Region)

      return set_path_with_clip(path, clip) if clip

      path_bounds = path.bounds
      clip = Region.new(IRect.new(path_bounds.left.floor, path_bounds.top.floor, path_bounds.right.ceil, path_bounds.bottom.ceil))
      begin
        set_path_with_clip(path, clip)
      ensure
        clip.close
      end
    end

    def translate(x, y)
      Native.sk_region_translate(@ptr, x.to_i, y.to_i)
      self
    end

    def op(other, operation)
      success = case other
                when IRect then Native.sk_region_op_rect(@ptr, other.to_struct, operation)
                when Region then Native.sk_region_op(@ptr, other.ptr, operation)
                else raise ArgumentError, 'other must be a Skia::IRect or Region'
                end
      raise Error, "Failed to apply region operation: #{operation}" unless success

      self
    end

    def each
      return enum_for(__method__) unless block_given?

      iterator = Native.sk_region_iterator_new(@ptr)
      begin
        until Native.sk_region_iterator_done(iterator)
          rect = Native::SKIRect.new
          Native.sk_region_iterator_rect(iterator, rect)
          yield IRect.from_struct(rect)
          Native.sk_region_iterator_next(iterator)
        end
      ensure
        Native.sk_region_iterator_delete(iterator)
      end
      self
    end

    private

    def set_path_with_clip(path, clip)
      Native.sk_region_set_path(@ptr, path.ptr, clip.ptr)
      self
    end
  end
end
