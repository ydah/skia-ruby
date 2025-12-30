# Skia Ruby

Ruby bindings for the Skia 2D graphics library.

## Overview

This gem provides Ruby bindings for Skia, Google's high-performance 2D graphics library. It uses FFI (Foreign Function Interface) to interface with SkiaSharp's C API, enabling hardware-accelerated graphics rendering from Ruby.

## Requirements

- Ruby 3.0 or later
- SkiaSharp native library (libSkiaSharp)

### Installing SkiaSharp

**macOS:**
```bash
# Download from SkiaSharp releases
curl -L -o skiasharp.nupkg https://www.nuget.org/api/v2/package/SkiaSharp.NativeAssets.macOS
unzip skiasharp.nupkg -d skiasharp-extract
cp skiasharp-extract/runtimes/osx/native/libSkiaSharp.dylib .
```

**Linux:**
```bash
curl -L -o skiasharp.nupkg https://www.nuget.org/api/v2/package/SkiaSharp.NativeAssets.Linux.x64
unzip skiasharp.nupkg -d skiasharp-extract
cp skiasharp-extract/runtimes/linux-x64/native/libSkiaSharp.so .
```

**Windows:**
```powershell
Invoke-WebRequest -Uri https://www.nuget.org/api/v2/package/SkiaSharp.NativeAssets.Win32 -OutFile skiasharp.nupkg
Expand-Archive skiasharp.nupkg -DestinationPath skiasharp-extract
copy skiasharp-extract\runtimes\win-x64\native\libSkiaSharp.dll .
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'skia'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install skia
```

## Usage

### Basic Example

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

### Drawing Shapes

```ruby
surface = Skia::Surface.make_raster(400, 400)

surface.draw do |canvas|
  canvas.clear(Skia::Color::WHITE)

  paint = Skia::Paint.new
  paint.antialias = true

  # Rectangle
  paint.color = Skia::Color::BLUE
  canvas.draw_rect(Skia::Rect.from_xywh(50, 50, 100, 80), paint)

  # Circle
  paint.color = Skia::Color::RED
  canvas.draw_circle(250, 100, 50, paint)

  # Oval
  paint.color = Skia::Color::GREEN
  canvas.draw_oval(Skia::Rect.from_xywh(150, 200, 150, 80), paint)

  # Rounded rectangle
  paint.color = Skia::Color::MAGENTA
  canvas.draw_round_rect(Skia::Rect.from_xywh(50, 300, 120, 60), 15, paint)

  # Line
  paint.style = :stroke
  paint.stroke_width = 3
  paint.color = Skia::Color::BLACK
  canvas.draw_line(300, 200, 380, 350, paint)
end

surface.save_png('shapes.png')
```

### Using Paths

```ruby
path = Skia::Path.build do
  move_to 100, 100
  line_to 200, 100
  line_to 200, 200
  quad_to 150, 250, 100, 200
  close
end

surface.draw do |canvas|
  paint = Skia::Paint.new
  paint.color = Skia::Color.rgb(255, 128, 0)
  canvas.draw_path(path, paint)
end
```

### Gradients

```ruby
surface.draw do |canvas|
  # Linear gradient
  shader = Skia::Shader.linear_gradient(
    Skia::Point.new(0, 0),
    Skia::Point.new(400, 0),
    [Skia::Color::RED, Skia::Color::YELLOW, Skia::Color::BLUE]
  )

  paint = Skia::Paint.new
  paint.shader = shader
  canvas.draw_rect(Skia::Rect.from_xywh(0, 0, 400, 200), paint)

  # Radial gradient
  radial = Skia::Shader.radial_gradient(
    Skia::Point.new(200, 300),
    80,
    [Skia::Color::WHITE, Skia::Color::BLUE]
  )

  paint.shader = radial
  canvas.draw_circle(200, 300, 80, paint)
end
```

### Text Drawing

```ruby
surface.draw do |canvas|
  canvas.clear(Skia::Color::WHITE)

  font = Skia::Font.new(nil, 48.0)
  paint = Skia::Paint.new
  paint.antialias = true
  paint.color = Skia::Color::BLACK

  canvas.draw_text('Hello, Skia!', 50, 100, font, paint)

  # Measure text
  width, bounds = font.measure_text('Hello, Skia!')
  puts "Text width: #{width}"
end
```

### Canvas Transformations

```ruby
surface.draw do |canvas|
  canvas.clear(Skia::Color::WHITE)

  paint = Skia::Paint.new
  paint.color = Skia::Color::BLUE

  # Save state, transform, draw, restore
  canvas.with_save do
    canvas.translate(200, 200)
    canvas.rotate(45)
    canvas.draw_rect(Skia::Rect.from_xywh(-50, -50, 100, 100), paint)
  end

  # Scale
  canvas.with_save do
    canvas.translate(100, 100)
    canvas.scale(2.0, 0.5)
    paint.color = Skia::Color::RED
    canvas.draw_circle(0, 0, 30, paint)
  end
end
```

### PDF Output

```ruby
Skia::Document.create_pdf('output.pdf') do |doc|
  doc.begin_page(612, 792) do |canvas|
    canvas.clear(Skia::Color::WHITE)

    font = Skia::Font.new(nil, 24.0)
    paint = Skia::Paint.new
    paint.color = Skia::Color::BLACK

    canvas.draw_text('Hello, PDF!', 50, 100, font, paint)
  end

  doc.begin_page(612, 792) do |canvas|
    canvas.clear(Skia::Color::WHITE)
    # Second page content
  end
end
```

### Picture Recording

```ruby
bounds = Skia::Rect.from_xywh(0, 0, 200, 200)

picture = Skia::Picture.record(bounds) do |canvas|
  paint = Skia::Paint.new
  paint.color = Skia::Color::RED
  canvas.draw_circle(100, 100, 80, paint)
end

# Replay on different surfaces
surface.draw do |canvas|
  canvas.translate(50, 50)
  picture.playback(canvas)

  canvas.translate(250, 0)
  canvas.scale(0.5, 0.5)
  picture.playback(canvas)
end

# Serialize/deserialize
data = picture.serialize
loaded = Skia::Picture.from_data(data)
```

### Image Loading and Saving

```ruby
# Load image
image = Skia::Image.from_file('input.png')
puts "Image size: #{image.width}x#{image.height}"

# Draw image
surface.draw do |canvas|
  canvas.draw_image(image, 0, 0)
end

# Save in different formats
surface.save_png('output.png')
surface.save_jpeg('output.jpg', quality: 90)
surface.save_webp('output.webp', quality: 80)
```

## API Reference

### Main Classes

- `Skia::Surface` - Drawing surface (raster or GPU-backed)
- `Skia::Canvas` - Drawing context with transformation and clipping
- `Skia::Paint` - Style and color settings for drawing
- `Skia::Path` - Vector path for complex shapes
- `Skia::Image` - Immutable bitmap image
- `Skia::Shader` - Gradient and pattern fills
- `Skia::Font` - Font for text rendering
- `Skia::Typeface` - Font family and style
- `Skia::Document` - Multi-page document (PDF)
- `Skia::Picture` - Recorded drawing commands

### Geometry Classes

- `Skia::Point` - 2D point (x, y)
- `Skia::Rect` - Rectangle (left, top, right, bottom)
- `Skia::Matrix` - 3x3 transformation matrix
- `Skia::Color` - ARGB color value

### Constants

Paint styles:
- `:fill` - Fill shapes
- `:stroke` - Outline shapes
- `:stroke_and_fill` - Both fill and outline

Stroke caps:
- `:butt` - Flat cap
- `:round` - Round cap
- `:square` - Square cap

Stroke joins:
- `:miter` - Sharp corners
- `:round` - Rounded corners
- `:bevel` - Beveled corners

Blend modes:
- `:src_over`, `:multiply`, `:screen`, `:overlay`, etc.

## Development

After checking out the repo, run:

```bash
bundle install
bundle exec rspec
```

To run examples:

```bash
ruby examples/basic_drawing.rb
ruby examples/gradient.rb
ruby examples/bar_chart.rb
```

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

This project is licensed under the [BSD 3-Clause License](LICENSE).

## Acknowledgments

- [Skia Graphics Library](https://skia.org/)
- [SkiaSharp](https://github.com/mono/SkiaSharp)
- [Ruby FFI](https://github.com/ffi/ffi)
