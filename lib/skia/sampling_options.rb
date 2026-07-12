# frozen_string_literal: true

module Skia
  class SamplingOptions
    attr_reader :filter, :mipmap, :cubic_b, :cubic_c, :max_anisotropy

    def initialize(filter: :nearest, mipmap: :none, cubic_b: nil, cubic_c: nil, max_anisotropy: 0)
      raise ArgumentError, 'cubic_b and cubic_c must be provided together' if cubic_b.nil? != cubic_c.nil?

      @filter = filter
      @mipmap = mipmap
      @cubic_b = cubic_b&.to_f
      @cubic_c = cubic_c&.to_f
      @max_anisotropy = max_anisotropy.to_i
    end

    def self.default
      @default ||= new
    end

    def self.linear(mipmap: :none)
      new(filter: :linear, mipmap: mipmap)
    end

    def self.cubic(b: 1.0 / 3.0, c: 1.0 / 3.0)
      new(cubic_b: b, cubic_c: c)
    end

    def to_struct
      struct = Native::SKSamplingOptions.new
      struct[:fMaxAniso] = @max_anisotropy
      struct[:fUseCubic] = @cubic_b.nil? ? 0 : 1
      struct[:fCubicB] = @cubic_b || 0.0
      struct[:fCubicC] = @cubic_c || 0.0
      struct[:fFilter] = @filter
      struct[:fMipmap] = @mipmap
      struct
    end
  end
end
