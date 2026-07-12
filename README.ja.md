# Skia Ruby

[![Gem Version](https://badge.fury.io/rb/skia.svg)](https://rubygems.org/gems/skia)
[![CI](https://github.com/ydah/skia-ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/ydah/skia-ruby/actions/workflows/ci.yml)
[![Documentation](https://img.shields.io/badge/docs-rubydoc.info-blue)](https://rubydoc.info/gems/skia)

[English](README.md)

Skia Ruby は Google Skia の Ruby バインディングです。2D 描画、画像処理、PDF、RuntimeEffect、Skottie、SVG path/DOM を扱えます。

## 必要環境

- Ruby 3.2 以上
- SkiaSharp ネイティブライブラリ

## インストール

Gemfile に追加します。

```ruby
gem 'skia'
```

続いて gem とネイティブライブラリをインストールします。

```bash
bundle install
bundle exec skia-install-native
```

ネイティブライブラリはユーザーデータディレクトリへ保存され、以後は自動検出されます。独自ビルドを使う場合は
`SKIA_LIBRARY_PATH` にファイルまたはディレクトリを指定してください。ロードに失敗した場合は、探索したパスと対処方法が表示されます。

## 基本的な使い方

```ruby
require 'skia'

Skia::Surface.make_raster(640, 480) do |surface|
  surface.draw do |canvas|
    canvas.clear(Skia::Color::WHITE)

    paint = Skia::Paint.new
    paint.antialias = true
    paint.color = Skia::Color::RED
    canvas.draw_circle(320, 240, 100, paint)
  end

  surface.save_png('output.png')
end
```

Surface の factory にブロックを渡すと、正常終了・例外終了のどちらでもネイティブリソースを確実に解放します。ブロックなしの
factory も利用でき、その場合は GC による解放に加えて `surface.close` で明示的に解放できます。

## 主な機能

- `Surface` / `Canvas` / `Paint` / `Path` による描画
- PNG / JPEG / WebP の読み書き
- PDF と Picture の生成
- gradient、filter、RuntimeEffect
- Typeface / Font / TextBlob
- Skottie アニメーションの読み込みと描画
- SVG path の解析・生成と簡易 SVG DOM
- RBS 型定義と YARD API リファレンス
- Active Storage variant、OGP カード、CLI

ネイティブビルドに対象シンボルがない機能は、クラッシュさせず `UnsupportedOperationError` と不足シンボル名を返します。

## スレッドと Ractor

独立した Surface などを別々のスレッドで生成・描画できます。同じ可変ネイティブオブジェクトを複数スレッドから同時利用する場合の
同期は呼び出し側の責任です。FFI のネイティブオブジェクトは Ractor 間で共有せず、所有する Ractor 内で生成・利用してください。

## 開発

```bash
bundle install
bundle exec rake
bundle exec rbs validate
bundle exec steep check
bundle exec rake docs
```

API リファレンスは [rubydoc.info/gems/skia](https://rubydoc.info/gems/skia) で参照できます。

機能ごとのネイティブ ABI 制約は [機能サポート表](docs/feature-support.md)、Rails・静的サイト・GPU 連携は
[連携レシピ](docs/integrations.md) を参照してください。画像リサイズの任意比較ベンチは次のコマンドで実行できます。

```bash
bundle exec ruby benchmark/image_resize.rb
```

## ライセンス

[MIT License](LICENSE)
