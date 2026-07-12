# frozen_string_literal: true

require 'json'
require 'optparse'

module Skia
  class CLI
    def self.run(argv, out: $stdout, err: $stderr)
      new(out: out, err: err).run(argv)
    end

    def initialize(out:, err:)
      @out = out
      @err = err
    end

    def run(argv)
      command = argv.shift
      return print_help if command.nil? || %w[-h --help help].include?(command)

      case command
      when 'render' then render_script(argv)
      when 'lottie' then render_lottie(argv)
      when 'info' then image_info(argv)
      else
        raise OptionParser::InvalidArgument, "unknown command: #{command}"
      end
      0
    rescue OptionParser::ParseError, ArgumentError, Skia::Error, SystemCallError => e
      @err.puts("skia: #{e.message}")
      1
    end

    private

    def print_help
      @out.puts <<~HELP
        Usage: skia COMMAND [options]

          render SCRIPT -o FILE       evaluate a Ruby drawing script
          lottie INPUT -o FILE        render one Lottie frame
          info IMAGE                  print image metadata as JSON
      HELP
      0
    end

    def render_script(argv)
      options = { quality: 100 }
      parser = output_parser(options, 'Usage: skia render SCRIPT -o FILE')
      parser.parse!(argv)
      source = required_input!(argv, parser)
      result = Object.new.instance_eval(File.read(source), source, 1)
      write_result(result, options)
    end

    def render_lottie(argv)
      options = { frame: 0.0, quality: 100 }
      parser = output_parser(options, 'Usage: skia lottie INPUT -o FILE')
      parser.on('--frame NUMBER', Float, 'frame number') { |value| options[:frame] = value }
      parser.on('--width PIXELS', Integer, 'output width') { |value| options[:width] = value }
      parser.on('--height PIXELS', Integer, 'output height') { |value| options[:height] = value }
      parser.parse!(argv)
      source = required_input!(argv, parser)
      animation = Skottie::Animation.make_from_file(source)
      natural_width, natural_height = animation.size.map(&:round)
      width = options.fetch(:width, natural_width)
      height = options.fetch(:height, natural_height)
      raise ArgumentError, 'width and height must be positive' unless width.positive? && height.positive?

      result = Surface.make_raster(width, height)
      animation.render_frame(result.canvas, frame: options[:frame], rect: Rect.from_wh(width, height))
      write_result(result, options)
    end

    def image_info(argv)
      parser = OptionParser.new { |value| value.banner = 'Usage: skia info IMAGE' }
      parser.parse!(argv)
      codec = Codec.from_file(required_input!(argv, parser))
      info = codec.info
      @out.puts JSON.pretty_generate(
        width: info.width,
        height: info.height,
        format: codec.format,
        origin: codec.origin,
        frame_count: codec.frame_count,
        repetition_count: codec.repetition_count
      )
    end

    def output_parser(options, banner)
      OptionParser.new do |parser|
        parser.banner = banner
        parser.on('-o', '--output FILE', 'output file') { |value| options[:output] = value }
        parser.on('-q', '--quality NUMBER', Integer, 'JPEG/WebP quality') { |value| options[:quality] = value }
      end
    end

    def required_input!(argv, parser)
      input = argv.shift
      raise OptionParser::MissingArgument, parser.banner unless input && argv.empty?

      input
    end

    def write_result(result, options)
      output = options[:output]
      raise OptionParser::MissingArgument, '--output' unless output

      case result
      when Surface, Image
        result.save(output, quality: options[:quality])
      when Data
        File.binwrite(output, result.to_s)
      else
        raise ArgumentError, "script must return Skia::Surface, Skia::Image, or Skia::Data (got #{result.class})"
      end
      @out.puts output
    end
  end
end
