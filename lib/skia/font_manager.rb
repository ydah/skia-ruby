# frozen_string_literal: true

module Skia
  class FontManager < Base
    include Enumerable

    def initialize(ptr = nil)
      native_ptr = ptr || Native.sk_fontmgr_create_default
      raise Error, 'Failed to create the default font manager' if native_ptr.nil? || native_ptr.null?

      super(native_ptr, :sk_fontmgr_unref)
    end

    def self.default
      new
    end

    def family_count
      Native.sk_fontmgr_count_families(@ptr)
    end

    def family_name(index)
      position = Integer(index)
      raise IndexError, "font family index out of range: #{position}" unless position.between?(0, family_count - 1)

      string = Native.sk_string_new_empty
      begin
        Native.sk_fontmgr_get_family_name(@ptr, position, string)
        read_string(string)
      ensure
        Native.sk_string_destructor(string)
      end
    end

    def families
      map { |name| name }
    end

    def each
      return enum_for(__method__) unless block_given?

      family_count.times { |index| yield family_name(index) }
      self
    end

    def match_family(name, weight: Typeface::WEIGHT_NORMAL, width: Typeface::WIDTH_NORMAL, slant: :upright)
      with_font_style(weight, width, slant) do |style|
        wrap_typeface(Native.sk_fontmgr_match_family_style(@ptr, name.to_s, style))
      end
    end

    def match_character(character, family: nil, languages: [], weight: Typeface::WEIGHT_NORMAL,
                        width: Typeface::WIDTH_NORMAL, slant: :upright)
      codepoint = character.is_a?(String) ? character.ord : Integer(character)
      raise RangeError, 'character must be a valid Unicode codepoint' unless codepoint.between?(0, 0x10FFFF)

      language_ptr, language_storage = language_array(languages)
      with_font_style(weight, width, slant) do |style|
        typeface = Native.sk_fontmgr_match_family_style_character(
          @ptr, family.to_s, style, language_ptr, language_storage.length, codepoint
        )
        wrap_typeface(typeface)
      end
    end

    def make_from_file(path, index: 0)
      ptr = Native.sk_fontmgr_create_from_file(@ptr, path.to_s, index.to_i)
      raise FileNotFoundError, "Failed to load typeface: #{path}" if ptr.nil? || ptr.null?

      Typeface.new(ptr)
    end

    def make_from_data(data, index: 0)
      data_object = data.is_a?(Data) ? data : Data.new(data)
      ptr = Native.sk_fontmgr_create_from_data(@ptr, data_object.ptr, index.to_i)
      raise Error, 'Failed to create typeface from data' if ptr.nil? || ptr.null?

      Typeface.new(ptr)
    end

    private

    def with_font_style(weight, width, slant)
      style = Native.sk_fontstyle_new(weight.to_i, width.to_i, slant)
      raise Error, 'Failed to create font style' if style.nil? || style.null?

      begin
        yield style
      ensure
        Native.sk_fontstyle_delete(style)
      end
    end

    def language_array(languages)
      strings = languages.map { |language| FFI::MemoryPointer.from_string(language.to_s) }
      return [nil, strings] if strings.empty?

      pointer = FFI::MemoryPointer.new(:pointer, strings.length)
      pointer.write_array_of_pointer(strings)
      [pointer, strings]
    end

    def wrap_typeface(ptr)
      return nil if ptr.nil? || ptr.null?

      Typeface.new(ptr)
    end

    def read_string(ptr)
      data = Native.sk_string_get_c_str(ptr)
      size = Native.sk_string_get_size(ptr)
      return '' if data.nil? || data.null? || size.zero?

      data.read_string(size)
    end
  end
end
