# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Vertices do
  it 'copies indexed vertex data' do
    vertices = described_class.make_copy(
      :triangles,
      [[0, 0], [10, 0], [0, 10]],
      texture_coords: [[0, 0], [1, 0], [0, 1]],
      colors: [Skia::Color::RED, Skia::Color::GREEN, Skia::Color::BLUE],
      indices: [0, 1, 2]
    )

    expect(vertices).to be_a(described_class)
  end

  it 'validates matching array sizes and indices' do
    expect do
      described_class.make_copy(:triangles, [[0, 0]], colors: [])
    end.to raise_error(ArgumentError, /same length/)

    expect do
      described_class.make_copy(:triangles, [[0, 0]], indices: [1])
    end.to raise_error(ArgumentError, /indices/)
  end
end
