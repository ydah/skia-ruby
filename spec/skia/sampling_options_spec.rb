# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::SamplingOptions do
  it 'builds linear sampling options' do
    struct = described_class.linear(mipmap: :linear).to_struct

    expect(struct[:fFilter]).to eq(:linear)
    expect(struct[:fMipmap]).to eq(:linear)
    expect(struct[:fUseCubic]).to eq(0)
  end

  it 'builds cubic sampling options' do
    struct = described_class.cubic(b: 0.25, c: 0.5).to_struct

    expect(struct[:fUseCubic]).to eq(1)
    expect(struct[:fCubicB]).to eq(0.25)
    expect(struct[:fCubicC]).to eq(0.5)
  end
end
