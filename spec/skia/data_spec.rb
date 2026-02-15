# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Data do
  describe '.new' do
    it 'creates data from a string' do
      data = described_class.new('hello world')
      expect(data.size).to eq(11)
      expect(data.to_s).to eq('hello world')
    end

    it 'creates data from binary content' do
      binary = [0x89, 0x50, 0x4E, 0x47].pack('C*')
      data = described_class.new(binary)
      expect(data.size).to eq(4)
    end
  end

  describe '#size' do
    it 'returns the data size' do
      data = described_class.new('test')
      expect(data.size).to eq(4)
    end
  end

  describe '#to_s' do
    it 'returns the data as a string' do
      data = described_class.new('hello')
      expect(data.to_s).to eq('hello')
    end
  end

  describe '#empty?' do
    it 'returns true for empty data' do
      data = described_class.new('')
      expect(data).to be_empty
    end

    it 'returns false for non-empty data' do
      data = described_class.new('x')
      expect(data).not_to be_empty
    end
  end
end
