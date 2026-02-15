FROM --platform=linux/amd64 ruby:3.3

WORKDIR /app

RUN apt-get update && apt-get install -y unzip curl && rm -rf /var/lib/apt/lists/*

RUN curl -L --retry 3 -o skiasharp.nupkg "https://www.nuget.org/api/v2/package/SkiaSharp.NativeAssets.Linux/3.119.0" && \
    unzip -o skiasharp.nupkg -d skiasharp-extract && \
    cp skiasharp-extract/runtimes/linux-x64/native/libSkiaSharp.so . && \
    rm -rf skiasharp.nupkg skiasharp-extract

COPY Gemfile Gemfile.lock* skia-ruby.gemspec ./
COPY lib/skia/version.rb lib/skia/version.rb

RUN bundle install

COPY . .

ENV LD_LIBRARY_PATH=/app

CMD ["bundle", "exec", "rspec"]
