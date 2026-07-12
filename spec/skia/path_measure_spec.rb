# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::PathMeasure do
  subject(:measure) do
    path = Skia::Path.new.move_to(0, 0).line_to(3, 4)
    described_class.new(path)
  end

  it 'measures path length' do
    expect(measure.length).to be_within(0.001).of(5.0)
    expect(measure).not_to be_contour_closed
  end

  it 'returns position and tangent at a distance' do
    position, tangent = measure.position_tangent(2.5)

    expect(position.x).to be_within(0.001).of(1.5)
    expect(position.y).to be_within(0.001).of(2.0)
    expect(tangent.x).to be_within(0.001).of(0.6)
    expect(tangent.y).to be_within(0.001).of(0.8)
  end

  it 'returns a position and tangent matrix' do
    matrix = measure.matrix(2.5)

    expect(matrix.trans_x).to be_within(0.001).of(1.5)
    expect(matrix.trans_y).to be_within(0.001).of(2.0)
  end

  it 'can be reset to another path' do
    measure.set_path(Skia::Path.new.move_to(0, 0).line_to(10, 0))

    expect(measure.length).to be_within(0.001).of(10.0)
  end
end
