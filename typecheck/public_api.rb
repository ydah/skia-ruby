# frozen_string_literal: true

surface = Skia::Surface.make_raster(32, 32)
canvas = surface.canvas
paint = Skia::Paint.new
paint.color = Skia::Color::RED
paint.antialias = true

path = Skia::Path.build
path.move_to(0, 0).line_to(32, 32)
canvas.draw_path(path, paint)

image = surface.snapshot
image.save('typecheck.png', format: :png)
surface.close
