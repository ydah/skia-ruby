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

    PathNode = Struct.new(
      :path_data, :fill, :stroke, :stroke_width, :text, :x, :y, :font_size,
      keyword_init: true
    )

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

      def render(width, height)
        raise ArgumentError, 'a drawing block is required' unless block_given?

        register_native_symbols!
        ensure_native_function!(:sk_svgcanvas_create_with_stream, '.render')
        stream = Native.sk_dynamicmemorywstream_new
        raise Error, 'Failed to create SVG output stream' if stream.nil? || stream.null?

        canvas = create_canvas(Rect.from_wh(width, height), stream)
        begin
          yield canvas
          canvas.close
          data_ptr = Native.sk_dynamicmemorywstream_detach_as_data(stream)
          raise Error, 'Failed to create SVG data' if data_ptr.nil? || data_ptr.null?

          Data.new(data_ptr)
        ensure
          canvas&.close
          Native.sk_dynamicmemorywstream_destroy(stream)
        end
      end

      def save(path, width:, height:, &)
        data = render(width, height, &)
        File.binwrite(path, data.to_s)
        path
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
        end
      end

      private

      def register_native_symbols!
        return if @native_symbols_registered

        Native.optional_attach_function :sk_path_parse_svg_string, %i[sk_path_t string], :bool
        Native.optional_attach_function :sk_path_to_svg_string, %i[sk_path_t sk_string_t], :void
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

      def create_canvas(bounds, stream)
        ptr = Native.sk_svgcanvas_create_with_stream(bounds.to_struct, stream)
        raise Error, 'Failed to create SVG canvas' if ptr.nil? || ptr.null?

        Canvas.new(ptr, owner: stream, release_method: :sk_canvas_destroy)
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

        gradients = extract_gradients(source, width, height)
        path_nodes = extract_nodes(source)

        new(width: width, height: height, paths: path_nodes, gradients: gradients)
      end

      def initialize(width:, height:, paths:, gradients: {})
        @width = width&.to_f
        @height = height&.to_f
        @paths = paths
        @gradients = gradients
      end

      def empty?
        @paths.empty?
      end

      def draw(canvas, x: 0.0, y: 0.0, paint: nil)
        @paths.each do |node|
          canvas.with_save do
            canvas.translate(x.to_f, y.to_f)
            if node.text
              render_text(canvas, node, paint)
            else
              render_path(canvas, Svg.parse_path(node.path_data), node, paint)
            end
          end
        end

        self
      end

      private

      def render_text(canvas, node, override_paint)
        text_paint = override_paint || Paint.new
        unless override_paint
          text_paint.antialias = true
          apply_fill(text_paint, node.fill || Color::BLACK)
        end
        canvas.draw_text(node.text, node.x || 0, node.y || 0, Font.new(nil, node.font_size || 16), text_paint)
      end

      def render_path(canvas, path, node, override_paint)
        if override_paint
          canvas.draw_path(path, override_paint)
          return
        end

        if node.fill
          fill_paint = Paint.new
          fill_paint.antialias = true
          fill_paint.style = :fill
          apply_fill(fill_paint, node.fill)
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

      def apply_fill(paint, fill)
        value = resolve_fill(fill)
        if value.is_a?(Shader)
          paint.shader = value
        elsif value.is_a?(Color)
          paint.color = value
        end
      end

      def resolve_fill(fill)
        return fill unless fill.is_a?(String)

        match = fill.match(/\Aurl\(\s*#([^\s)]+)\s*\)\z/i)
        match ? @gradients[match[1]] : nil
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
        source.to_s.scan(/([:\w-]+)\s*=\s*("([^"]*)"|'([^']*)')/).each do |name, _quoted, double_quoted, single_quoted|
          attributes[name] = double_quoted || single_quoted || ''
        end
        attributes
      end

      def self.extract_nodes(source)
        nodes = []
        source.scan(%r{<path\b([^>]*)/?>}im).each do |match|
          attributes = parse_attributes(match.first.to_s)
          add_path_node(nodes, attributes, attributes['d'])
        end
        extract_rects(source, nodes)
        extract_circles(source, nodes)
        extract_ellipses(source, nodes)
        extract_lines(source, nodes)
        extract_polygons(source, nodes)
        extract_text(source, nodes)
        nodes
      end

      def self.extract_gradients(source, width, height)
        gradients = {}
        source.scan(%r{<linearGradient\b([^>]*)>(.*?)</linearGradient>}im).each do |attribute_source, content|
          attributes = parse_attributes(attribute_source)
          colors, positions = gradient_stops(content)
          next if attributes['id'].to_s.empty? || colors.length < 2

          start_point = Point.new(gradient_length(attributes['x1'], width, 0), gradient_length(attributes['y1'], height, 0))
          end_point = Point.new(gradient_length(attributes['x2'], width, width), gradient_length(attributes['y2'], height, 0))
          gradients[attributes['id']] = Shader.linear_gradient(start_point, end_point, colors, positions)
        end
        source.scan(%r{<radialGradient\b([^>]*)>(.*?)</radialGradient>}im).each do |attribute_source, content|
          attributes = parse_attributes(attribute_source)
          colors, positions = gradient_stops(content)
          next if attributes['id'].to_s.empty? || colors.length < 2

          center = Point.new(gradient_length(attributes['cx'], width, width / 2.0),
                             gradient_length(attributes['cy'], height, height / 2.0))
          radius = gradient_length(attributes['r'], [width, height].min, [width, height].min / 2.0)
          gradients[attributes['id']] = Shader.radial_gradient(center, radius, colors, positions)
        end
        gradients
      end

      def self.gradient_stops(source)
        stops = source.scan(%r{<stop\b([^>]*)/?>}im).filter_map do |match|
          attributes = parse_attributes(match.first.to_s)
          style = attributes['style'].to_s.split(';').filter_map { |entry| entry.split(':', 2) if entry.include?(':') }.to_h
          color = Svg.parse_color(attributes['stop-color'] || style['stop-color'])
          next unless color

          opacity = Float(attributes['stop-opacity'] || style['stop-opacity'] || 1)
          offset = percentage(attributes['offset'] || 0)
          [color.with_alpha((color.alpha * opacity.clamp(0, 1)).round), offset.clamp(0, 1)]
        rescue ArgumentError
          nil
        end
        [stops.map(&:first), stops.map(&:last)]
      end

      def self.gradient_length(value, extent, default)
        return default.to_f if value.nil?
        return percentage(value) * extent.to_f if value.to_s.include?('%')

        Float(value)
      rescue ArgumentError
        default.to_f
      end

      def self.percentage(value)
        source = value.to_s.strip
        source.end_with?('%') ? Float(source.delete_suffix('%')) / 100.0 : Float(source)
      end

      def self.extract_rects(source, nodes)
        source.scan(%r{<rect\b([^>]*)/?>}im).each do |match|
          attributes = parse_attributes(match.first.to_s)
          x = parse_length(attributes['x']) || 0
          y = parse_length(attributes['y']) || 0
          width = parse_length(attributes['width'])
          height = parse_length(attributes['height'])
          next unless width&.positive? && height&.positive?

          add_path_node(nodes, attributes, "M #{x} #{y} H #{x + width} V #{y + height} H #{x} Z")
        end
      end

      def self.extract_circles(source, nodes)
        source.scan(%r{<circle\b([^>]*)/?>}im).each do |match|
          attributes = parse_attributes(match.first.to_s)
          center_x = parse_length(attributes['cx']) || 0
          center_y = parse_length(attributes['cy']) || 0
          radius = parse_length(attributes['r'])
          next unless radius&.positive?

          data = "M #{center_x - radius} #{center_y} " \
                 "A #{radius} #{radius} 0 1 0 #{center_x + radius} #{center_y} " \
                 "A #{radius} #{radius} 0 1 0 #{center_x - radius} #{center_y} Z"
          add_path_node(nodes, attributes, data)
        end
      end

      def self.extract_ellipses(source, nodes)
        source.scan(%r{<ellipse\b([^>]*)/?>}im).each do |match|
          attributes = parse_attributes(match.first.to_s)
          center_x = parse_length(attributes['cx']) || 0
          center_y = parse_length(attributes['cy']) || 0
          radius_x = parse_length(attributes['rx'])
          radius_y = parse_length(attributes['ry'])
          next unless radius_x&.positive? && radius_y&.positive?

          data = "M #{center_x - radius_x} #{center_y} " \
                 "A #{radius_x} #{radius_y} 0 1 0 #{center_x + radius_x} #{center_y} " \
                 "A #{radius_x} #{radius_y} 0 1 0 #{center_x - radius_x} #{center_y} Z"
          add_path_node(nodes, attributes, data)
        end
      end

      def self.extract_lines(source, nodes)
        source.scan(%r{<line\b([^>]*)/?>}im).each do |match|
          attributes = parse_attributes(match.first.to_s)
          x1 = parse_length(attributes['x1']) || 0
          y1 = parse_length(attributes['y1']) || 0
          x2 = parse_length(attributes['x2']) || 0
          y2 = parse_length(attributes['y2']) || 0
          add_path_node(nodes, attributes, "M #{x1} #{y1} L #{x2} #{y2}")
        end
      end

      def self.extract_polygons(source, nodes)
        source.scan(%r{<(polyline|polygon)\b([^>]*)/?>}im).each do |tag, attribute_source|
          attributes = parse_attributes(attribute_source)
          points = attributes['points'].to_s.scan(/-?\d+(?:\.\d+)?/).map(&:to_f).each_slice(2).to_a
          next if points.empty? || points.any? { |point| point.length != 2 }

          data = "M #{points.first.join(' ')} "
          data += points.drop(1).map { |point| "L #{point.join(' ')}" }.join(' ')
          data += ' Z' if tag.downcase == 'polygon'
          add_path_node(nodes, attributes, data)
        end
      end

      def self.extract_text(source, nodes)
        source.scan(%r{<text\b([^>]*)>(.*?)</text>}im).each do |attribute_source, content|
          attributes = parse_attributes(attribute_source)
          nodes << styled_node(
            attributes,
            text: decode_entities(content.gsub(/<[^>]+>/, '').strip),
            x: parse_length(attributes['x']) || 0,
            y: parse_length(attributes['y']) || 0,
            font_size: parse_length(attributes['font-size']) || 16
          )
        end
      end

      def self.add_path_node(nodes, attributes, path_data)
        return if path_data.nil? || path_data.strip.empty?

        nodes << styled_node(attributes, path_data: path_data)
      end

      def self.styled_node(attributes, **values)
        fill = Svg.parse_color(attributes['fill'])
        fill ||= attributes['fill'] if attributes['fill'].to_s.match?(/\Aurl\(/i)
        PathNode.new(
          **values,
          fill: fill,
          stroke: Svg.parse_color(attributes['stroke']),
          stroke_width: parse_length(attributes['stroke-width'])
        )
      end

      def self.decode_entities(value)
        value.gsub('&lt;', '<').gsub('&gt;', '>').gsub('&quot;', '"').gsub('&apos;', "'").gsub('&amp;', '&')
      end
    end
  end
end
