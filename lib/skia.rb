# frozen_string_literal: true

require 'ffi'

require_relative 'skia/version'
require_relative 'skia/native'
require_relative 'skia/base'
require_relative 'skia/color'
require_relative 'skia/point'
require_relative 'skia/rect'
require_relative 'skia/matrix'
require_relative 'skia/paint'
require_relative 'skia/path'
require_relative 'skia/data'
require_relative 'skia/image'
require_relative 'skia/surface'
require_relative 'skia/canvas'
require_relative 'skia/typeface'
require_relative 'skia/font'
require_relative 'skia/shader'
require_relative 'skia/document'
require_relative 'skia/picture'

module Skia
  class Error < StandardError; end
  class NullPointerError < Error; end
  class EncodingError < Error; end
  class DecodingError < Error; end
  class FileNotFoundError < Error; end
  class UnsupportedOperationError < Error; end
end
