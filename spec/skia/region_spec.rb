# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Region do
  subject(:region) { described_class.new(Skia::IRect.from_xywh(0, 0, 20, 10)) }

  it 'reports bounds and containment' do
    expect(region).to be_rect
    expect(region.bounds).to eq(Skia::IRect.from_xywh(0, 0, 20, 10))
    expect(region.contains?(5, 5)).to be true
    expect(region.contains?(25, 5)).to be false
  end

  it 'combines regions with boolean operations' do
    region.op(Skia::IRect.from_xywh(10, 0, 20, 10), :union)

    expect(region.bounds).to eq(Skia::IRect.from_xywh(0, 0, 30, 10))
  end

  it 'enumerates its rectangles' do
    region.op(Skia::IRect.from_xywh(5, 0, 5, 10), :difference)

    expect(region.to_a).to contain_exactly(
      Skia::IRect.from_xywh(0, 0, 5, 10),
      Skia::IRect.from_xywh(10, 0, 10, 10)
    )
  end

  it 'creates a region from a path' do
    path = Skia::Path.new.add_rect(Skia::Rect.from_xywh(2, 3, 8, 6))
    path_region = described_class.new(path)

    expect(path_region.contains?(5, 5)).to be true
    expect(path_region.boundary_path).to be_a(Skia::Path)
  end
end
