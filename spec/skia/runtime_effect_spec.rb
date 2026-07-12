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

  describe 'metadata' do
    it 'lists uniforms and their byte size' do
      effect = described_class.make_for_shader(<<~SKSL)
        uniform float intensity;
        half4 main(float2 coord) { return half4(intensity); }
      SKSL

      expect(effect.uniform_names).to eq(['intensity'])
      expect(effect.uniform_byte_size).to eq(4)
      expect(effect.child_names).to eq([])
    end
  end

  describe 'color filter and blender effects' do
    it 'creates a runtime color filter' do
      effect = described_class.make_for_color_filter(<<~SKSL)
        half4 main(half4 color) { return color; }
      SKSL

      expect(effect.make_color_filter).to be_a(Skia::ColorFilter)
    end

    it 'creates a runtime blender' do
      effect = described_class.make_for_blender(<<~SKSL)
        half4 main(half4 source, half4 destination) { return source + destination * 0.0; }
      SKSL

      expect(effect.make_blender).to be_a(Skia::Blender)
    end
  end
end
