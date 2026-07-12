# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Blender do
  it 'creates an immortal blend mode wrapper without taking ownership' do
    blender = described_class.mode(:multiply)

    expect(blender).to be_a(described_class)
    expect(blender.instance_variable_get(:@release_method)).to be_nil
  end

  it 'creates an owned arithmetic blender' do
    blender = described_class.arithmetic(0, 1, 1, 0, enforce_premul: true)

    expect(blender).to be_a(described_class)
    expect(blender.instance_variable_get(:@release_method)).to eq(:sk_blender_unref)
  end
end
