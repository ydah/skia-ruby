# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::RuntimeEffect do
  let(:sksl) do
    <<~SKSL
      half4 main(float2 coord) {
        return half4(coord.x / 128.0, coord.y / 128.0, 0.25, 1.0);
      }
    SKSL
  end

  describe '.make_for_shader' do
    it 'raises UnsupportedOperationError when runtime effect native APIs are unavailable' do
      allow(Skia::Native).to receive(:function_available?).and_call_original
      allow(Skia::Native).to receive(:function_available?).with(:sk_runtimeeffect_make_for_shader).and_return(false)

      expect { described_class.make_for_shader(sksl) }.to raise_error(Skia::UnsupportedOperationError)
    end

    it 'compiles a shader runtime effect' do
      effect = described_class.make_for_shader(sksl)
      expect(effect).to be_a(described_class)
    end

    it 'raises on invalid sksl' do
      expect { described_class.make_for_shader('this is not sksl') }.to raise_error(Skia::Error)
    end
  end

  describe '#make_shader' do
    it 'creates a shader and can be used for drawing' do
      effect = described_class.make_for_shader(sksl)
      shader = effect.make_shader

      paint = Skia::Paint.new
      paint.shader = shader

      surface = Skia::Surface.make_raster(64, 64)
      surface.canvas.draw_rect(Skia::Rect.from_xywh(0, 0, 64, 64), paint)

      bytes = surface.read_pixels(width: 4, height: 4)
      expect(bytes.bytesize).to eq(4 * 4 * 4)
    end
  end
end
