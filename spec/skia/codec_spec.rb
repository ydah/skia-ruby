# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Codec do
  let(:gif_data) do
    [
      '47494638396101000100f00000ff000000000021ff0b4e45545343415045322e30030100000021f9040005000000' \
      '2c000000000100010000020244010021f90400070000002c0000000001000100800000ff00000002024401003b'
    ].pack('H*')
  end
  subject(:codec) { described_class.from_data(gif_data) }

  it 'reads encoded image metadata' do
    expect(codec.format).to eq(:gif)
    expect(codec.origin).to eq(:top_left)
    expect(codec.info.width).to eq(1)
    expect(codec.info.height).to eq(1)
  end

  it 'reports animation frame metadata' do
    expect(codec.frame_count).to eq(2)
    expect(codec.frame_infos.map(&:duration)).to eq([50, 70])
  end

  it 'decodes frames into images' do
    image = codec.decode_frame

    expect(image).to be_a(Skia::Image)
    expect([image.width, image.height]).to eq([1, 1])
    expect(image.read_pixels.bytesize).to eq(4)
  end

  it 'decodes animated frames in sequence' do
    frames = codec.decode_frames

    expect(frames.map(&:read_pixels)).to eq(
      ["\xFF\x00\x00\xFF".b, "\x00\x00\xFF\xFF".b]
    )
  end

  it 'validates frame indices' do
    expect { codec.decode_frame(2) }.to raise_error(IndexError)
  end

  it 'applies encoded orientation while decoding' do
    encoded = Skia::Surface.make_raster(2, 1) do |surface|
      surface.canvas.clear(Skia::Color::RED)
      paint = Skia::Paint.new
      paint.color = Skia::Color::BLUE
      surface.canvas.draw_rect(Skia::Rect.from_xywh(1, 0, 1, 1), paint)
      surface.encode(:png)
    end
    oriented_codec = described_class.from_data(encoded)
    allow(oriented_codec).to receive(:origin).and_return(:right_top)

    image = oriented_codec.decode_frame

    expect([image.width, image.height]).to eq([1, 2])
    expect(image.read_pixels).to eq("\xFF\x00\x00\xFF\x00\x00\xFF\xFF".b)
  end
end
