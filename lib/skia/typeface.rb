# frozen_string_literal: true

module Skia
  class Typeface < Base
    WEIGHT_NORMAL = 400
    WEIGHT_BOLD = 700
    WIDTH_NORMAL = 5

    def initialize(ptr)
      super(ptr, :sk_typeface_unref)
    end

    def self.from_name(name, weight: WEIGHT_NORMAL, width: WIDTH_NORMAL, slant: :upright)
      style = Native.sk_fontstyle_new(weight, width, slant)
      begin
        ptr = Native.sk_typeface_create_from_name(name, style)
        return nil if ptr.nil? || ptr.null?

        new(ptr)
      ensure
        Native.sk_fontstyle_delete(style) if style && !style.null?
      end
    end

    def self.from_file(path, index = 0)
      ptr = Native.sk_typeface_create_from_file(path, index)
      raise FileNotFoundError, "Failed to load typeface: #{path}" if ptr.nil? || ptr.null?

      new(ptr)
    end

    def self.default
      ptr = Native.sk_typeface_create_default
      return nil if ptr.nil? || ptr.null?

      new(ptr)
    end

    def family_name
      read_native_string(:sk_typeface_get_family_name)
    end

    def post_script_name
      return nil unless Native.function_available?(:sk_typeface_get_post_script_name)

      read_native_string(:sk_typeface_get_post_script_name)
    end

    def weight
      Native.sk_typeface_get_font_weight(@ptr)
    end

    def width
      Native.sk_typeface_get_font_width(@ptr)
    end

    def slant
      Native.sk_typeface_get_font_slant(@ptr)
    end

    def fixed_pitch?
      Native.sk_typeface_is_fixed_pitch(@ptr)
    end

    def units_per_em
      Native.sk_typeface_get_units_per_em(@ptr)
    end

    def glyph_count
      Native.sk_typeface_count_glyphs(@ptr)
    end

    def style
      {
        weight: weight,
        width: width,
        slant: slant,
        fixed_pitch: fixed_pitch?,
        units_per_em: units_per_em
      }
    end

    def table_count
      Native.sk_typeface_count_tables(@ptr)
    end

    def table_tags
      count = table_count
      return [] if count <= 0

      tags_ptr = FFI::MemoryPointer.new(:uint32, count)
      read_count = Native.sk_typeface_get_table_tags(@ptr, tags_ptr)
      tags_ptr.read_array_of_uint32(read_count).map { |tag| self.class.tag_to_string(tag) }
    end

    def table_data(tag)
      tag_u32 = self.class.tag_to_uint32(tag)
      size = Native.sk_typeface_get_table_size(@ptr, tag_u32)
      return nil if size <= 0

      data_ptr = FFI::MemoryPointer.new(:uint8, size)
      bytes_read = Native.sk_typeface_get_table_data(@ptr, tag_u32, 0, size, data_ptr)
      return nil if bytes_read <= 0

      data_ptr.read_bytes(bytes_read)
    end

    def variation_axes
      fvar = table_data('fvar')
      return [] if fvar.nil? || fvar.bytesize < 16

      version, offset_to_data, = fvar.unpack('Nn')
      return [] unless version == 0x0001_0000

      axis_count = fvar.byteslice(8, 2).unpack1('n')
      axis_size = fvar.byteslice(10, 2).unpack1('n')
      return [] if axis_count <= 0 || axis_size < 20

      axes = []
      axis_count.times do |index|
        offset = offset_to_data + (index * axis_size)
        break if offset + 20 > fvar.bytesize

        record = fvar.byteslice(offset, 20)
        tag = record.byteslice(0, 4)
        min_raw, default_raw, max_raw, flags, name_id = record.byteslice(4, 16).unpack('N3n2')

        axes << {
          tag: tag,
          min_value: self.class.fixed_16_16_to_float(min_raw),
          default_value: self.class.fixed_16_16_to_float(default_raw),
          max_value: self.class.fixed_16_16_to_float(max_raw),
          hidden: flags.anybits?(0x0001),
          name_id: name_id
        }
      end

      axes
    end

    private

    def read_native_string(function_name)
      string_ptr = Native.send(function_name, @ptr)
      return nil if string_ptr.nil? || string_ptr.null?

      begin
        cstr = Native.sk_string_get_c_str(string_ptr)
        size = Native.sk_string_get_size(string_ptr)
        cstr.read_string(size)
      ensure
        Native.sk_string_destructor(string_ptr)
      end
    end

    def self.tag_to_string(tag_u32)
      big_endian = [tag_u32].pack('N')
      return big_endian if big_endian.match?(/\A[\x20-\x7E]{4}\z/)

      [tag_u32].pack('V')
    end

    def self.tag_to_uint32(tag)
      return tag if tag.is_a?(Integer)
      raise ArgumentError, 'tag must be a 4-character String or Integer' unless tag.is_a?(String) && tag.bytesize == 4

      tag.unpack1('N')
    end

    def self.fixed_16_16_to_float(raw)
      signed = raw >= 0x8000_0000 ? raw - 0x1_0000_0000 : raw
      signed / 65_536.0
    end
  end
end
