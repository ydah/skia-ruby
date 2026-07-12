# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::ColorFilter do
  let(:identity_matrix) do
    [
      1, 0, 0, 0, 0,
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 1, 0
    ]
  end

  it 'creates RGBA and HSLA matrix filters' do
    expect(described_class.matrix(identity_matrix)).to be_a(described_class)
    expect(described_class.hsla_matrix(identity_matrix)).to be_a(described_class)
  end

  it 'creates composed and interpolated filters' do
    first = described_class.mode(Skia::Color::RED)
    second = described_class.lighting(Skia::Color::WHITE, Skia::Color::BLACK)

    expect(described_class.compose(first, second)).to be_a(described_class)
    expect(described_class.lerp(0.5, first, second)).to be_a(described_class)
  end

  it 'creates gamma and luma filters' do
    expect(described_class.srgb_to_linear_gamma).to be_a(described_class)
    expect(described_class.linear_to_srgb_gamma).to be_a(described_class)
    expect(described_class.luma).to be_a(described_class)
  end

  it 'creates table filters' do
    table = Array.new(256) { |index| index }

    expect(described_class.table(table)).to be_a(described_class)
    expect(described_class.argb_table(alpha: table, red: table, green: table, blue: table)).to be_a(described_class)
  end

  it 'validates matrix and table sizes' do
    expect { described_class.matrix([1, 2]) }.to raise_error(ArgumentError, /20/)
    expect { described_class.table([1, 2]) }.to raise_error(ArgumentError, /256/)
  end
end
