# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'thread safety' do
  it 'renders independent surfaces concurrently' do
    results = 8.times.map do |index|
      Thread.new do
        Skia::Surface.make_raster(16, 16) do |surface|
          surface.canvas.clear(index.even? ? Skia::Color::RED : Skia::Color::BLUE)
          surface.read_pixels(width: 1, height: 1)
        end
      end
    end.map(&:value)

    expect(results).to all(satisfy { |pixels| pixels.bytesize == 4 })
  end
end
