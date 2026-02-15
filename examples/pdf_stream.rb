#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/skia'

doc = Skia::Document.create_pdf_stream(metadata: { title: 'Skia PDF Stream', author: 'skia-ruby' })

doc.page(595, 842) do |canvas|
  canvas.clear(Skia::Color::WHITE)

  paint = Skia::Paint.new
  paint.color = Skia::Color::BLACK

  font = Skia::Font.new(nil, 28)
  canvas.draw_text('PDF from memory stream', 48, 96, font, paint)

  paint.color = Skia::Color::BLUE
  canvas.draw_circle(160, 220, 64, paint)
end

data = doc.to_data
File.binwrite('stream_output.pdf', data.to_s)
puts 'Saved stream_output.pdf'
