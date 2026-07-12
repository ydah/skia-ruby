# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'golden image rendering' do
  it 'preserves known RGBA pixels through PNG encoding and decoding' do
    encoded = Skia::Surface.make_raster(2, 2) do |surface|
      surface.canvas.clear(Skia::Color::RED)
      surface.encode(:png)
    end
    decoded = Skia::Image.from_data(encoded)

    expected_rgba = "\xFF\x00\x00\xFF".b * 4
    expect(decoded.read_pixels).to eq(expected_rgba)
  end
end
