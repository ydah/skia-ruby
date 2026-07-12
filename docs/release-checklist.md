# Release checklist

## One-time setup

1. On RubyGems.org, register this repository as a Trusted Publisher for the `skia` gem.
2. Set the workflow filename to `release.yml` and the GitHub environment to `release`.
3. Create the protected `release` environment in GitHub repository settings.
4. Configure Codecov for the repository. Add `CODECOV_TOKEN` only when the organization requires authenticated uploads.

## Release

1. Update `Skia::VERSION` and `CHANGELOG.md`.
2. Run `bundle exec rake`, `bundle exec rbs validate`, `bundle exec steep check`, and `bundle exec rake docs`.
3. Build the package with `gem build skia-ruby.gemspec` and inspect its file list.
4. Commit the version and changelog changes.
5. Create and push a signed `v<version>` tag.
6. Confirm that `.github/workflows/release.yml` publishes through RubyGems Trusted Publishing.
7. Verify the gem page, installation command, and generated rubydoc.info reference.

The release workflow uses short-lived GitHub OIDC credentials. Do not add a long-lived RubyGems API key to repository secrets.
