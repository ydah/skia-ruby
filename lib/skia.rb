# frozen_string_literal: true

require 'ffi'

require_relative 'skia/version'
require_relative 'skia/native'
require_relative 'skia/base'
require_relative 'skia/color'
require_relative 'skia/color_space'
require_relative 'skia/point'
require_relative 'skia/rect'
require_relative 'skia/rrect'
require_relative 'skia/image_info'
require_relative 'skia/matrix'
require_relative 'skia/sampling_options'
require_relative 'skia/rotation_scale_matrix'
require_relative 'skia/paint'
require_relative 'skia/path'
require_relative 'skia/path_measure'
require_relative 'skia/region'
require_relative 'skia/vertices'
require_relative 'skia/mask_filter'
require_relative 'skia/color_filter'
require_relative 'skia/blender'
require_relative 'skia/image_filter'
require_relative 'skia/path_effect'
require_relative 'skia/data'
require_relative 'skia/pixmap'
require_relative 'skia/bitmap'
require_relative 'skia/image'
require_relative 'skia/codec'
require_relative 'skia/surface'
require_relative 'skia/canvas'
require_relative 'skia/typeface'
require_relative 'skia/font_manager'
require_relative 'skia/font'
require_relative 'skia/text_blob'
require_relative 'skia/textlayout'
require_relative 'skia/runtime_effect'
require_relative 'skia/skottie'
require_relative 'skia/svg'
require_relative 'skia/shader'
require_relative 'skia/document'
require_relative 'skia/picture'

module Skia
  class Error < StandardError; end
  class NullPointerError < Error; end
  class ClosedError < Error; end
  class EncodingError < Error; end
  class DecodingError < Error; end
  class FileNotFoundError < Error; end
  class UnsupportedOperationError < Error; end
end
