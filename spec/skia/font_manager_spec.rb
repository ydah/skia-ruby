# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::FontManager do
  subject(:manager) { described_class.default }

  it 'lists installed font families' do
    expect(manager.family_count).to be >= 0
    expect(manager.families.length).to eq(manager.family_count)
  end

  it 'gets a family name and matches its normal style' do
    skip 'no system fonts are installed' if manager.family_count.zero?

    name = manager.family_name(0)
    typeface = manager.match_family(name)

    expect(name).not_to be_empty
    expect(typeface).to be_a(Skia::Typeface)
  end

  it 'matches a typeface for a Unicode character' do
    skip 'no system fonts are installed' if manager.family_count.zero?

    typeface = manager.match_character('A', languages: ['en'])

    expect(typeface).to be_a(Skia::Typeface)
  end

  it 'validates family indices and Unicode codepoints' do
    expect { manager.family_name(manager.family_count) }.to raise_error(IndexError)
    expect { manager.match_character(0x11_0000) }.to raise_error(RangeError)
  end
end
