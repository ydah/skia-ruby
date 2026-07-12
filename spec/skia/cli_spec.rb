# frozen_string_literal: true

require 'spec_helper'
require 'skia/cli'
require 'stringio'
require 'tmpdir'

RSpec.describe Skia::CLI do
  def run_cli(*arguments)
    out = StringIO.new
    err = StringIO.new
    status = described_class.run(arguments, out: out, err: err)
    [status, out.string, err.string]
  end

  it 'renders the final value of a Ruby script' do
    Dir.mktmpdir do |directory|
      script = File.join(directory, 'drawing.rb')
      output = File.join(directory, 'drawing.png')
      File.write(script, 'Skia::Surface.make_raster(12, 8) { |surface| surface.canvas.clear(Skia::Color::RED); surface.snapshot }')

      status, stdout, stderr = run_cli('render', script, '-o', output)

      expect(status).to eq(0)
      expect(stdout).to include(output)
      expect(stderr).to be_empty
      expect(File.binread(output)).to start_with("\x89PNG".b)
    end
  end

  it 'prints image metadata as JSON' do
    Dir.mktmpdir do |directory|
      path = File.join(directory, 'input.png')
      Skia::Surface.make_raster(9, 7).save_png(path)

      status, stdout, = run_cli('info', path)
      metadata = JSON.parse(stdout)

      expect(status).to eq(0)
      expect(metadata).to include('width' => 9, 'height' => 7, 'frame_count' => 1)
    end
  end

  it 'returns a failure status for invalid scripts' do
    Dir.mktmpdir do |directory|
      script = File.join(directory, 'drawing.rb')
      File.write(script, 'Object.new')

      status, _, stderr = run_cli('render', script, '-o', File.join(directory, 'drawing.png'))

      expect(status).to eq(1)
      expect(stderr).to include('script must return')
    end
  end
end
