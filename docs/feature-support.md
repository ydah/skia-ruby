# Feature support and native ABI limits

The gem targets the public C ABI exported by libSkiaSharp. A C++ Skia feature is not automatically callable from FFI;
it must also be exported by that ABI. Optional entry points are checked at runtime and raise
`Skia::UnsupportedOperationError` with the missing capability.

## Supported with platform or build conditions

- XPS documents: available on Windows libSkiaSharp builds through `Document.create_xps` and
  `Document.create_xps_stream`. Other platforms fail before page creation.
- Paragraph shaping: the Ruby API is present, but requires a native build exporting skparagraph, skshaper, and
  skunicode symbols. Standard libSkiaSharp packages commonly omit them.
- GPU surfaces: constructors are available when the native build exports them, but the application must own and pass
  valid native graphics-context/backend pointers. Ruby FFI cannot infer these from a GLFW or SDL window.

## Deliberately not exposed as working APIs

- `Path.interpolate`: no path-interpolation entry point is exported. Applications can resample both paths with
  `PathMeasure` and build a new path when their contour topology is controlled.
- Animated GIF/WebP encoding: libSkiaSharp exports still-image PNG, JPEG, and WebP encoders, but no animated encoder.
  `Codec` does decode animated GIF/WebP frames. Use a dedicated animation encoder after producing frames.
- Skottie markers and dynamic text/color property handles: the required observer/property symbols are not exported.
  Resource providers, font managers, frame seeking, and rendering are supported.
- Full SVG/CSS conformance: paths, basic shapes, text, grouped content, and linear/radial gradients are implemented.
  Filters, masks, external stylesheets, and the complete SVG transform/inheritance model are outside the current DOM.
- A built-in GLFW/SDL context creator: context creation is backend- and platform-specific. The gem accepts explicit
  native context and backend handles instead of guessing ownership across two FFI libraries.

`Canvas#draw_shadow` and `Canvas#draw_text_on_path` are portable Ruby-layer implementations built from exported blur,
text-blob rotation, and path-measurement primitives.
