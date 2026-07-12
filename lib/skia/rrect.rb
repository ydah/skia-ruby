# frozen_string_literal: true

module Skia
  class RRect < Base
    CORNERS = %i[upper_left upper_right lower_right lower_left].freeze
    TYPES = %i[empty rect oval simple nine_patch complex].freeze

    def initialize(ptr = nil)
      created = ptr.nil?
      ptr ||= Native.sk_rrect_new
      raise Error, 'Failed to create rounded rectangle' if ptr.nil? || ptr.null?

      super(ptr, :sk_rrect_delete)
      Native.sk_rrect_set_empty(@ptr) if created
    end

    def self.from_rect(rect)
      rrect = new
      rrect.set_rect(rect)
      rrect
    end

    def self.from_rect_xy(rect, x_radius, y_radius = x_radius)
      rrect = new
      rrect.set_rect_xy(rect, x_radius, y_radius)
      rrect
    end

    def self.from_rect_radii(rect, radii)
      rrect = new
      rrect.set_rect_radii(rect, radii)
      rrect
    end

    def clone
      ptr = Native.sk_rrect_new_copy(@ptr)
      raise Error, 'Failed to clone rounded rectangle' if ptr.nil? || ptr.null?

      self.class.new(ptr)
    end

    def rect
      rect_struct = Native::SKRect.new
      Native.sk_rrect_get_rect(@ptr, rect_struct)
      Rect.from_struct(rect_struct)
    end

    def set_empty
      Native.sk_rrect_set_empty(@ptr)
      self
    end

    def set_rect(rect)
      rect_struct = rect.to_struct
      Native.sk_rrect_set_rect(@ptr, rect_struct)
      self
    end

    def set_rect_xy(rect, x_radius, y_radius = x_radius)
      rect_struct = rect.to_struct
      Native.sk_rrect_set_rect_xy(@ptr, rect_struct, x_radius.to_f, y_radius.to_f)
      self
    end

    def set_rect_radii(rect, radii)
      raise ArgumentError, 'radii must have 4 entries (ul, ur, lr, ll)' unless radii.is_a?(Array) && radii.length == 4

      rect_struct = rect.to_struct
      radii_ptr = FFI::MemoryPointer.new(Native::SKPoint, 4)

      radii.each_with_index do |radius, index|
        point = case radius
                when Point
                  radius
                when Array
                  raise ArgumentError, 'radius pair must have 2 elements' unless radius.length == 2

                  Point.new(radius[0], radius[1])
                else
                  raise ArgumentError, 'radius must be Point or [x, y]'
                end

        radius_struct = point.to_struct
        destination = Native::SKPoint.new(radii_ptr + (index * Native::SKPoint.size))
        destination[:x] = radius_struct[:x]
        destination[:y] = radius_struct[:y]
      end

      Native.sk_rrect_set_rect_radii(@ptr, rect_struct, radii_ptr)
      self
    end

    def corner_radius(corner)
      raise ArgumentError, "Invalid corner: #{corner.inspect}. Expected one of: #{CORNERS.join(', ')}" unless CORNERS.include?(corner)

      point_struct = Native::SKPoint.new
      Native.sk_rrect_get_radii(@ptr, corner, point_struct)
      Point.from_struct(point_struct)
    end

    def type
      Native.sk_rrect_get_type(@ptr)
    end

    def width
      Native.sk_rrect_get_width(@ptr)
    end

    def height
      Native.sk_rrect_get_height(@ptr)
    end

    def valid?
      Native.sk_rrect_is_valid(@ptr)
    end

    def contains_rect?(rect)
      rect_struct = rect.to_struct
      Native.sk_rrect_contains(@ptr, rect_struct)
    end

    def inset(dx, dy)
      Native.sk_rrect_inset(@ptr, dx.to_f, dy.to_f)
      self
    end

    def outset(dx, dy)
      Native.sk_rrect_outset(@ptr, dx.to_f, dy.to_f)
      self
    end

    def offset(dx, dy)
      Native.sk_rrect_offset(@ptr, dx.to_f, dy.to_f)
      self
    end
  end
end
