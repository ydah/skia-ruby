# frozen_string_literal: true

require_relative 'lib/skia/version'

Gem::Specification.new do |spec|
  spec.name = 'skia'
  spec.version = Skia::VERSION
  spec.authors = ['Yudai Takada']
  spec.email = ['t.yudai92@gmail.com']

  spec.summary = 'Ruby bindings for Google Skia 2D graphics library'
  spec.description = 'Ruby bindings for Skia, providing high-performance 2D graphics capabilities'
  spec.homepage = 'https://github.com/ydah/skia-ruby'
  spec.license = 'BSD-3-Clause'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile Dockerfile])
    end
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'ffi', '~> 1.15'
end
