#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/skia'

Skia::Card.new(
  title: 'Building Ruby Bindings for Skia Graphics Library with FFI',
  author: '@ruby_dev',
  site_name: 'tech.blog',
  tags: %w[Ruby FFI Graphics]
).save('social_card.png')

puts 'Saved to social_card.png'
