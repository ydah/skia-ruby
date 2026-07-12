# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- Added PathOps, `PathMeasure`, SVG path serialization, `Region`, region clipping, and quick-reject APIs.
- Added sampled image resizing and scaling, animated GIF/WebP frame decoding, EXIF orientation handling, and optional
  `Pixmap`/`Numo::NArray` conversion.
- Added mesh and sprite drawing with `Canvas#draw_vertices`, `#draw_atlas`, and `#draw_patch`.
- Added softened path shadows and text drawing along paths.
- Added system font enumeration and fallback matching through `FontManager`.
- Added color-matrix/table filters, `Blender`, and RuntimeEffect color-filter/blender support.
- Added Skottie font and external/data-URI resource providers.
- Added SVG canvas output and SVG DOM rendering for paths, basic shapes, text, groups, and linear/radial gradients.
- Added XPS file and memory documents on Windows libSkiaSharp builds.
- Added an Active Storage variant transformer supporting resize, fill, crop, pad, rotate, and format conversion.
- Added `Skia::Card` for social-card generation and the `skia` CLI for scripts, image metadata, and Lottie frames.
- Added deterministic block forms for `Surface` factories and explicit `close`/`closed?` lifecycle APIs.

### Changed

- Ruby 3.2 or newer is now required.
- Native installation is available through `skia-install-native`; installed libraries are discovered automatically from
  the user data directory and load errors list all searched paths.
- Saving to an unsupported image format now raises `UnsupportedOperationError` instead of writing PNG data with a
  mismatched extension.

### Fixed

- Prevented canvases, borrowed pixel views, paint effects, and direct raster buffers from outliving their native owners.
- Corrected sampled `draw_image` and `draw_image_rect` native calls to match the libSkiaSharp ABI.

## 1.0.0 - 2026-02-15

- Initial release
