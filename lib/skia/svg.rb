# frozen_string_literal: true

module Skia
  module Svg
    REQUIRED_NATIVE_SYMBOLS = %i[
      sk_path_parse_svg_string
      sk_path_to_svg_string
    ].freeze

    NAMED_COLORS = {
      'black' => Color::BLACK,
      'white' => Color::WHITE,
      'red' => Color::RED,
      'green' => Color::GREEN,
      'blue' => Color::BLUE,
      'yellow' => Color::YELLOW,
      'cyan' => Color::CYAN,
      'magenta' => Color::MAGENTA,
      'transparent' => Color::TRANSPARENT
    }.freeze

    PathNode = Struct.new(:path_data, :fill, :stroke, :stroke_width, keyword_init: true)

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
              "Svg#{api_name} is not supported by the current libSkiaSharp (missing #{missing.join(', ')})"
      end

      def parse_path(path_data)
        ensure_available!('.parse_path')

        path = Path.new
        success = Native.sk_path_parse_svg_string(path.ptr, path_data.to_s)
        raise Error, 'Failed to parse SVG path string' unless success

        path
      end

      def path_to_svg(path)
        ensure_available!('.path_to_svg')
        ensure_native_function!(:sk_path_to_svg_string, '.path_to_svg')

        str = Native.sk_string_new_empty
        raise Error, 'Failed to allocate SVG path output string' if str.nil? || str.null?

        begin
          Native.sk_path_to_svg_string(path.ptr, str)
          read_sk_string(str)
        ensure
          Native.sk_string_destructor(str) if str && !str.null?
        end
      end

      def parse_color(value)
        return nil if value.nil?

        source = value.to_s.strip.downcase
        return nil if source.empty? || source == 'none'
        return NAMED_COLORS[source] if NAMED_COLORS.key?(source)

        case source
        when /\A#[0-9a-f]{6}\z/
          Color.from_hex(source)
        when /\A#[0-9a-f]{8}\z/
          Color.from_hex(source)
        else
          nil
        end
      end

      private

      def register_native_symbols!
        return if @native_symbols_registered

        Native.optional_attach_function :sk_path_parse_svg_string, [:sk_path_t, :string], :bool
        Native.optional_attach_function :sk_path_to_svg_string, [:sk_path_t, :sk_string_t], :void
        Native.optional_attach_function :sk_svgcanvas_create_with_stream, [Native::SKRect.ptr, :pointer], :sk_canvas_t

        @native_symbols_registered = true
      end

      def ensure_native_function!(function_name, api_name)
        return if Native.function_available?(function_name)

        raise UnsupportedOperationError,
              "Svg#{api_name} is not supported by the current libSkiaSharp (missing #{function_name})"
      end

      def read_sk_string(ptr)
        return '' if ptr.nil? || ptr.null?

        cstr = Native.sk_string_get_c_str(ptr)
        size = Native.sk_string_get_size(ptr)
        return '' if cstr.nil? || cstr.null? || size.to_i.zero?

        cstr.read_string(size)
      end
    end

    class Dom
      attr_reader :width, :height, :paths

      def self.from_svg(svg_text)
        source = svg_text.to_s
        raise Error, 'Invalid SVG: empty input' if source.strip.empty?
        raise Error, 'Failed to parse SVG: malformed markup' if source.count('<') != source.count('>')

        root_match = source.match(/<svg\b([^>]*)>/im)
        raise Error, 'Invalid SVG: root <svg> element not found' unless root_match

        root_attributes = parse_attributes(root_match[1].to_s)
        width = parse_length(root_attributes['width']) || parse_view_box(root_attributes['viewBox'], 2)
        height = parse_length(root_attributes['height']) || parse_view_box(root_attributes['viewBox'], 3)

        path_nodes = []
        source.scan(/<path\b([^>]*)\/?>/im).each do |match|
          attributes = parse_attributes(match.first.to_s)
          path_data = attributes['d']
          next if path_data.nil? || path_data.strip.empty?

          path_nodes << PathNode.new(
            path_data: path_data,
            fill: Svg.parse_color(attributes['fill']),
            stroke: Svg.parse_color(attributes['stroke']),
            stroke_width: parse_length(attributes['stroke-width'])
          )
        end

        new(width: width, height: height, paths: path_nodes)
      end

      def initialize(width:, height:, paths:)
        @width = width&.to_f
        @height = height&.to_f
        @paths = paths
      end

      def empty?
        @paths.empty?
      end

      def draw(canvas, x: 0.0, y: 0.0, paint: nil)
        @paths.each do |node|
          path = Svg.parse_path(node.path_data)
          canvas.with_save do
            canvas.translate(x.to_f, y.to_f)
            render_path(canvas, path, node, paint)
          end
        end

        self
      end

      private

      def render_path(canvas, path, node, override_paint)
        if override_paint
          canvas.draw_path(path, override_paint)
          return
        end

        if node.fill
          fill_paint = Paint.new
          fill_paint.antialias = true
          fill_paint.style = :fill
          fill_paint.color = node.fill
          canvas.draw_path(path, fill_paint)
        end

        if node.stroke
          stroke_paint = Paint.new
          stroke_paint.antialias = true
          stroke_paint.style = :stroke
          stroke_paint.stroke_width = (node.stroke_width || 1.0)
          stroke_paint.color = node.stroke
          canvas.draw_path(path, stroke_paint)
        end

        return if node.fill || node.stroke

        default_paint = Paint.new
        default_paint.antialias = true
        default_paint.style = :fill
        default_paint.color = Color::BLACK
        canvas.draw_path(path, default_paint)
      end

      def self.parse_length(value)
        return nil if value.nil?

        match = value.to_s.strip.match(/\A(-?\d+(?:\.\d+)?)/)
        match ? match[1].to_f : nil
      end

      def self.parse_view_box(view_box, index)
        return nil if view_box.nil?

        parts = view_box.to_s.strip.split(/[\s,]+/)
        return nil unless parts.length == 4

        Float(parts[index])
      rescue ArgumentError
        nil
      end

      def self.parse_attributes(source)
        attributes = {}
        source.to_s.scan(/([:\w-]+)\s*=\s*(\"([^\"]*)\"|'([^']*)')/).each do |name, _quoted, double_quoted, single_quoted|
          attributes[name] = double_quoted || single_quoted || ''
        end
        attributes
      end
    end
  end
end
