# Integration recipes

## Rails Active Storage

Set the variant transformer after Active Storage has loaded:

```ruby
# config/initializers/active_storage_skia.rb
Rails.application.config.after_initialize do
  ActiveStorage.variant_transformer = Skia::ActiveStorageTransformer
end
```

Variants can then use `resize_to_limit`, `resize_to_fit`, `resize_to_fill`, `resize_and_pad`, `crop`, and `rotate`.
Unsupported commands raise before a source image is processed.

## Jekyll or another static-site build

Put a script in `scripts/social_cards.rb`:

```ruby
require 'skia'

posts.each do |post|
  Skia::Card.new(title: post.title, site_name: 'Example', tags: post.tags)
            .save("assets/cards/#{post.slug}.png")
end
```

Run it before the site generator in CI:

```yaml
- run: bundle exec skia-install-native
- run: bundle exec ruby scripts/social_cards.rb
- run: bundle exec jekyll build
```

Keep the generated cards in the build cache when post metadata has not changed.

## GPU window toolkits

Create the GLFW/SDL window and GPU backend in the library that owns them, then pass the native handles to
`Surface.make_render_target`, `Surface.make_backend_render_target`, or `Surface.make_backend_texture`. Keep the window,
graphics context, backend object, and Skia surface alive in that order; close the Skia surface before destroying the
context. CPU raster surfaces are the portable fallback for headless CI and server rendering.
