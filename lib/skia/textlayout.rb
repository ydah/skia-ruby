# frozen_string_literal: true

module Skia
  module Textlayout
    REQUIRED_NATIVE_SYMBOLS = %i[
      sk_shaper_new
      sk_shaper_delete
      sk_paragraph_builder_new
      sk_paragraph_builder_delete
      sk_paragraph_builder_add_text
      sk_paragraph_builder_build
      sk_paragraph_layout
      sk_paragraph_paint
      sk_paragraph_unref
    ].freeze

    class << self
      def available?
        missing_symbols.empty?
      end

      def missing_symbols
        register_native_symbols!
        REQUIRED_NATIVE_SYMBOLS.reject { |name| Native.function_available?(name) }
      end

      def ensure_available!(api_name = '')
        missing = missing_symbols
        return if missing.empty?

        raise UnsupportedOperationError,
              "Textlayout#{api_name} is not supported by the current libSkiaSharp (missing #{missing.join(', ')})"
      end

      private

      def register_native_symbols!
        return if @native_symbols_registered

        # Probe availability of textlayout/shaper APIs without requiring them.
        Native.optional_attach_function :sk_shaper_new, [], :pointer
        Native.optional_attach_function :sk_shaper_delete, [:pointer], :void
        Native.optional_attach_function :sk_paragraph_builder_new, [:pointer], :pointer
        Native.optional_attach_function :sk_paragraph_builder_delete, [:pointer], :void
        Native.optional_attach_function :sk_paragraph_builder_add_text, [:pointer, :pointer, :size_t], :void
        Native.optional_attach_function :sk_paragraph_builder_build, [:pointer], :pointer
        Native.optional_attach_function :sk_paragraph_layout, [:pointer, :float], :void
        Native.optional_attach_function :sk_paragraph_paint, [:pointer, :sk_canvas_t, :float, :float], :void
        Native.optional_attach_function :sk_paragraph_unref, [:pointer], :void

        @native_symbols_registered = true
      end
    end

    class ShapedText
      attr_reader :text, :glyphs, :positions

      def initialize(text:, glyphs:, positions:)
        @text = text
        @glyphs = glyphs
        @positions = positions
      end
    end

    class Shaper
      def self.shape(text, font)
        Textlayout.ensure_available!('.Shaper.shape')

        glyphs = font.text_to_glyphs(text.to_s)
        positions = font.glyph_x_positions(glyphs)
        ShapedText.new(text: text.to_s, glyphs: glyphs, positions: positions)
      end
    end

    class Paragraph
      attr_reader :text, :font, :paint, :layout_width

      def initialize(text, font:, paint:, line_height: nil)
        @text = text.to_s
        @font = font
        @paint = paint
        @line_height = line_height&.to_f
        @layout_width = nil
        @lines = []
        @layout_dirty = true
      end

      def layout(width)
        Textlayout.ensure_available!('.Paragraph#layout')

        @layout_width = width.to_f
        raise ArgumentError, 'width must be greater than 0' if @layout_width <= 0.0

        @lines = wrap_text(@text, @layout_width)
        @layout_dirty = false
        self
      end

      def lines
        relayout_if_needed
        @lines.dup
      end

      def draw(canvas, x, y)
        Textlayout.ensure_available!('.Paragraph#draw')
        relayout_if_needed

        baseline = y.to_f
        lines.each do |line|
          canvas.draw_text(line, x.to_f, baseline, font, paint)
          baseline += resolved_line_height
        end

        self
      end

      private

      def relayout_if_needed
        return unless @layout_dirty

        width = @layout_width || Float::INFINITY
        @lines = wrap_text(@text, width)
        @layout_dirty = false
      end

      def resolved_line_height
        return @line_height if @line_height && @line_height.positive?

        metrics = @font.metrics
        natural = (metrics.descent - metrics.ascent) + metrics.leading
        natural.positive? ? natural : @font.size
      end

      def wrap_text(text, width)
        source_lines = text.split("\n", -1)
        wrapped = []

        source_lines.each do |source_line|
          wrapped.concat(wrap_line(source_line, width))
        end

        wrapped
      end

      def wrap_line(line, width)
        return [line] if width.infinite? || width <= 0
        return [''] if line.empty?

        words = line.split(/\s+/)
        return [''] if words.empty?

        wrapped = []
        current = ''

        words.each do |word|
          candidate = current.empty? ? word : "#{current} #{word}"
          candidate_width, = @font.measure_text(candidate, @paint)

          if !current.empty? && candidate_width > width
            wrapped << current
            current = word
          else
            current = candidate
          end
        end

        wrapped << current unless current.empty?
        wrapped
      end
    end
  end
end
