# Skia Ruby

[![Gem Version](https://badge.fury.io/rb/skia.svg)](https://rubygems.org/gems/skia)
[![CI](https://github.com/ydah/skia-ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/ydah/skia-ruby/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/ydah/skia-ruby/graph/badge.svg)](https://codecov.io/gh/ydah/skia-ruby)
[![Documentation](https://img.shields.io/badge/docs-rubydoc.info-blue)](https://rubydoc.info/gems/skia)

[日本語](README.ja.md)

Skia bindings for Ruby, providing 2D drawing, image processing, PDF generation, runtime shaders, skottie animation, and SVG path/DOM rendering.

<img width="400" alt="Image" src="https://github.com/user-attachments/assets/440971a6-bf10-4cc2-abe6-e5cf28949b95" />

## Status

This project provides a practical, SkiaSharp-compatible API surface in Ruby, with a mix of:

- native-backed features through SkiaSharp C API
- Ruby convenience/typed layers for ergonomic usage

### Native-backed (current)

- `Surface` / `Canvas` / `Paint` / `Path` / `Image` / `Shader`
- Shape and path drawing (rect, rrect, arc, points, picture playback)
- `Document` PDF output
  - file output
  - memory stream output
  - metadata (`title`, `author`, `creation`, `pdfa`, etc.)
- `Picture` recording / playback / serialization
- `RuntimeEffect` (SkSL compile and shader creation)
- `Skottie` (Lottie JSON animation load/seek/render)
- Encoders (`PNG`, `JPEG`, `WEBP`)

### Ruby layer (current)

- Geometry/value types
  - `Point`, `Rect`, `RRect`, `Matrix`, `ImageInfo`, `ColorSpace`
- Effect wrappers
  - `MaskFilter`, `ColorFilter`, `ImageFilter`, `PathEffect`
- Pixel APIs
  - `Bitmap`, `Pixmap`, `read_pixels` helpers
- Text primitives
  - `Font`, `Typeface`, `TextBlob`
- Structured helpers
  - `Textlayout` (`Shaper`, `Paragraph`)
  - `Svg::Dom` (`<path>` load and draw)

### Native build note

- Text layout modules (`skunicode`, `skshaper`, `skparagraph`) are generally not exposed in `libSkiaSharp` builds.
- This gem checks symbol availability at runtime and raises `UnsupportedOperationError` with the missing symbol names.

## Requirements

- Ruby 3.2+
- SkiaSharp native library (`libSkiaSharp`)
  - macOS: `libSkiaSharp.dylib`
  - Linux: `libSkiaSharp.so`
  - Windows: `libSkiaSharp.dll`

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'skia'
```

Then run:

```bash
bundle install
```

Install the native library once in your user data directory:

```bash
bundle exec skia-install-native
```

The loader discovers that directory automatically; no environment variables are required.

## Installing Native Library

The gem loads `libSkiaSharp` from `SKIA_LIBRARY_PATH`, the user data directory, project/vendor directories,
the current working directory, or the system path. If loading fails, the error lists every searched path.

### Recommended (script-based)

Use the bundled installer scripts (defaults to prebuilt download):

```bash
scripts/install_native_skia.sh prebuilt
export SKIA_NATIVE_SOURCE=prebuilt
export SKIA_PREBUILT_DIR="$PWD/vendor/native/$(uname | tr '[:upper:]' '[:lower:]')"
```

For repository development, the equivalent Rake task is:

```bash
bundle exec rake skia:install_native
```

On Windows:

```powershell
.\scripts\install_native_skia.ps1 -Mode prebuilt
$env:SKIA_NATIVE_SOURCE = "prebuilt"
$env:SKIA_PREBUILT_DIR = "$pwd\\vendor\\native\\windows"
```

`SKIA_NATIVE_SOURCE` modes:

- `auto`: explicit path / local / prebuilt / system fallback
- `local`: use local library only (`SKIA_LIBRARY_PATH` required)
- `prebuilt`: use prebuilt vendor path (`SKIA_PREBUILT_DIR` or `vendor/native/<platform>`)

### macOS

```bash
curl -L -o skiasharp.nupkg \
  https://api.nuget.org/v3-flatcontainer/skiasharp.nativeassets.macos/3.119.2/skiasharp.nativeassets.macos.3.119.2.nupkg
unzip skiasharp.nupkg -d skiasharp-extract
cp skiasharp-extract/runtimes/osx/native/libSkiaSharp.dylib .
```

### Linux

```bash
curl -L -o skiasharp.nupkg https://www.nuget.org/api/v2/package/SkiaSharp.NativeAssets.Linux.x64
unzip skiasharp.nupkg -d skiasharp-extract
cp skiasharp-extract/runtimes/linux-x64/native/libSkiaSharp.so .
```

### Windows

```powershell
Invoke-WebRequest -Uri https://www.nuget.org/api/v2/package/SkiaSharp.NativeAssets.Win32 -OutFile skiasharp.nupkg
Expand-Archive skiasharp.nupkg -DestinationPath skiasharp-extract
copy skiasharp-extract\runtimes\win-x64\native\libSkiaSharp.dll .
```

## Quick Start

```ruby
require 'skia'

surface = Skia::Surface.make_raster(640, 480)

surface.draw do |canvas|
  canvas.clear(Skia::Color::WHITE)

  paint = Skia::Paint.new
  paint.antialias = true
  paint.color = Skia::Color::RED

  canvas.draw_circle(320, 240, 100, paint)
end

surface.save_png('output.png')
```

For deterministic cleanup, every `Surface` factory also accepts a block:

```ruby
Skia::Surface.make_raster(640, 480) do |surface|
  surface.canvas.clear(Skia::Color::WHITE)
  surface.save_png('output.png')
end # native surface is released here, including when the block raises
```

## PDF Example

```ruby
require 'skia'

Skia::Document.create_pdf('output.pdf', metadata: {
  title: 'My Report',
  author: 'skia-ruby',
  creation: Time.now,
  raster_dpi: 144.0,
  encoding_quality: 90
}) do |doc|
  doc.page(612, 792) do |canvas|
    canvas.clear(Skia::Color::WHITE)

    font = Skia::Font.new(nil, 24.0)
    paint = Skia::Paint.new
    paint.color = Skia::Color::BLACK

    canvas.draw_text('Hello, PDF!', 50, 100, font, paint)
  end
end
```

## Runtime Shader Example

```ruby
require 'skia'

sksl = <<~SKSL
  half4 main(float2 coord) {
    half r = coord.x / 640.0;
    half g = coord.y / 360.0;
    return half4(r, g, 0.35, 1.0);
  }
SKSL

effect = Skia::RuntimeEffect.make_for_shader(sksl)
shader = effect.make_shader

surface = Skia::Surface.make_raster(640, 360)
paint = Skia::Paint.new
paint.shader = shader

surface.draw do |canvas|
  canvas.draw_rect(Skia::Rect.from_wh(640, 360), paint)
end

surface.save_png('runtime_effect.png')
```

## API Coverage (Skia docs parity)

| Area | Status | Notes |
| --- | --- | --- |
| Core drawing (`Surface`/`Canvas`/`Paint`/`Path`) | Implemented | Main 2D drawing APIs are available |
| Shape/text primitives (`RRect`, `TextBlob`) | Implemented | Glyph-positioned drawing is supported via `TextBlob` |
| Effects (`MaskFilter`, `ColorFilter`, `ImageFilter`, `PathEffect`) | Implemented | Exposed through Ruby wrappers and `Paint` setters |
| Pixel and color APIs (`Bitmap`, `Pixmap`, `ImageInfo`, `ColorSpace`) | Implemented | Read/copy/access pixel-level data |
| Image and shader extensions | Implemented | Includes gradients and runtime shader compilation |
| PDF document APIs | Implemented | File/memory output and metadata are supported |
| `skottie` (Lottie) | Implemented | JSON load/seek/render via `Skia::Skottie::Animation` |
| SVG path / SVG DOM | Implemented | `Skia::Svg.parse_path`, `Skia::Svg::Dom` (`<path>` focused) |
| GPU-oriented surface constructors | Partial | Requires externally managed native GPU context pointers |
| Text layout modules (`skunicode`, `skshaper`, `skparagraph`) | Partial | Ruby API is available; native symbols may be absent depending on `libSkiaSharp` build |

## Development

After checking out the repo, install dependencies:

```bash
bundle install
```

Run examples:

```bash
ruby examples/basic_drawing.rb
ruby examples/gradient.rb
ruby examples/bar_chart.rb
ruby examples/advanced_features.rb
ruby examples/pdf_stream.rb
ruby examples/runtime_effect.rb
ruby examples/textlayout.rb
ruby examples/skottie.rb
ruby examples/svg_dom.rb
```

Release and upstream sync guidance: `docs/release-checklist.md`

Generate API documentation and validate the bundled RBS signatures with:

```bash
bundle exec rake docs
bundle exec rbs validate
bundle exec steep check
```

Published API reference: [rubydoc.info/gems/skia](https://rubydoc.info/gems/skia)

## Concurrency policy

- Independent `Surface`, `Canvas`, `Paint`, and other native objects may be created and used in separate threads.
- Do not use the same mutable native-backed object concurrently. Synchronization remains the caller's responsibility.
- A `Canvas` keeps its parent `Surface` alive, and borrowed pixel/effect objects keep their native owner alive.
- Native-backed objects are not Ractor-shareable. Build and render them inside the Ractor that owns them.

CI exercises independent surface rendering from multiple threads. Ractor support will require an isolation-safe FFI boundary and is not currently claimed.

## License

This project is available under the [MIT License](LICENSE).

## Contributing

Bug reports and pull requests are welcome at:

- https://github.com/ydah/skia-ruby
