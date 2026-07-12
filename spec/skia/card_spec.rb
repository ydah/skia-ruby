# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Card do
  it 'renders a social card with the requested dimensions' do
    card = described_class.new(title: 'A useful Ruby graphics guide', author: 'Rubyist', tags: %w[Ruby Skia], width: 600,
                               height: 315)
    surface = card.render

    expect([surface.width, surface.height]).to eq([600, 315])
    expect(surface.encode(:png).to_s).to start_with("\x89PNG".b)
  end

  it 'supports Japanese titles without whitespace' do
    card = described_class.new(title: 'Rubyで高速な画像生成を始める', width: 600, height: 315)

    expect { card.render }.not_to raise_error
  end

  it 'validates its required inputs' do
    expect { described_class.new(title: '') }.to raise_error(ArgumentError, /title/)
    expect { described_class.new(title: 'Title', colors: [Skia::Color::RED]) }.to raise_error(ArgumentError, /colors/)
  end
end
