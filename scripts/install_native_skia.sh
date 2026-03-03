#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-${SKIA_NATIVE_SOURCE:-prebuilt}}"
VERSION="${SKIASHARP_VERSION:-3.119.2}"

case "$(uname -s)" in
  Darwin)
    PLATFORM_KEY="darwin"
    PACKAGE="SkiaSharp.NativeAssets.macOS"
    RUNTIME_PATH="runtimes/osx/native/libSkiaSharp.dylib"
    LIB_NAME="libSkiaSharp.dylib"
    ;;
  Linux)
    PLATFORM_KEY="linux"
    PACKAGE="SkiaSharp.NativeAssets.Linux"
    RUNTIME_PATH="runtimes/linux-x64/native/libSkiaSharp.so"
    LIB_NAME="libSkiaSharp.so"
    ;;
  *)
    echo "Unsupported OS for this script. Use install_native_skia.ps1 on Windows." >&2
    exit 1
    ;;
esac

TARGET_ROOT="${SKIA_PREBUILT_DIR:-$(pwd)/vendor/native/${PLATFORM_KEY}}"
TARGET_LIB="${TARGET_ROOT}/${LIB_NAME}"

install_from_local() {
  local source_path="${SKIA_LIBRARY_PATH:-}"
  if [[ -z "${source_path}" ]]; then
    echo "SKIA_LIBRARY_PATH is required for local mode." >&2
    exit 1
  fi

  if [[ -d "${source_path}" ]]; then
    source_path="${source_path}/${LIB_NAME}"
  fi

  if [[ ! -f "${source_path}" ]]; then
    echo "Local library not found: ${source_path}" >&2
    exit 1
  fi

  mkdir -p "${TARGET_ROOT}"
  cp "${source_path}" "${TARGET_LIB}"
}

install_from_prebuilt() {
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  trap "rm -rf -- '${tmp_dir}'" EXIT

  local nupkg_url
  nupkg_url="https://www.nuget.org/api/v2/package/${PACKAGE}/${VERSION}"

  curl -L --retry 3 -o "${tmp_dir}/skiasharp.nupkg" "${nupkg_url}"
  unzip -o "${tmp_dir}/skiasharp.nupkg" -d "${tmp_dir}/extract" >/dev/null

  local extracted_lib
  extracted_lib="${tmp_dir}/extract/${RUNTIME_PATH}"
  if [[ ! -f "${extracted_lib}" ]]; then
    echo "Expected native library was not found in package: ${RUNTIME_PATH}" >&2
    exit 1
  fi

  mkdir -p "${TARGET_ROOT}"
  cp "${extracted_lib}" "${TARGET_LIB}"
}

case "${MODE}" in
  local)
    install_from_local
    ;;
  prebuilt|auto)
    install_from_prebuilt
    ;;
  *)
    echo "Unsupported mode: ${MODE}. Use local or prebuilt." >&2
    exit 1
    ;;
esac

echo "Installed: ${TARGET_LIB}"
echo "Next: export SKIA_NATIVE_SOURCE=prebuilt"
echo "Next: export SKIA_PREBUILT_DIR=${TARGET_ROOT}"
