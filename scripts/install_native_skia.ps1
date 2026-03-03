param(
  [ValidateSet('local', 'prebuilt', 'auto')]
  [string]$Mode = $(if ($env:SKIA_NATIVE_SOURCE) { $env:SKIA_NATIVE_SOURCE } else { 'prebuilt' })
)

$ErrorActionPreference = 'Stop'

$Version = if ($env:SKIASHARP_VERSION) { $env:SKIASHARP_VERSION } else { '3.119.2' }
$LibName = 'libSkiaSharp.dll'
$Package = 'SkiaSharp.NativeAssets.Win32'
$RuntimePath = 'runtimes/win-x64/native/libSkiaSharp.dll'
$TargetRoot = if ($env:SKIA_PREBUILT_DIR) {
  $env:SKIA_PREBUILT_DIR
} else {
  Join-Path (Get-Location) 'vendor/native/windows'
}
$TargetLib = Join-Path $TargetRoot $LibName

function Install-FromLocal {
  $sourcePath = $env:SKIA_LIBRARY_PATH
  if ([string]::IsNullOrEmpty($sourcePath)) {
    throw 'SKIA_LIBRARY_PATH is required for local mode.'
  }

  if (Test-Path $sourcePath -PathType Container) {
    $sourcePath = Join-Path $sourcePath $LibName
  }

  if (-not (Test-Path $sourcePath -PathType Leaf)) {
    throw "Local library not found: $sourcePath"
  }

  New-Item -ItemType Directory -Path $TargetRoot -Force | Out-Null
  Copy-Item $sourcePath $TargetLib -Force
}

function Install-FromPrebuilt {
  $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("skia-native-" + [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

  try {
    $nupkgPath = Join-Path $tmpDir 'skiasharp.nupkg'
    $extractDir = Join-Path $tmpDir 'extract'
    $nupkgUrl = "https://www.nuget.org/api/v2/package/$Package/$Version"

    Invoke-WebRequest -Uri $nupkgUrl -OutFile $nupkgPath
    Expand-Archive -Path $nupkgPath -DestinationPath $extractDir -Force

    $extractedLib = Join-Path $extractDir $RuntimePath
    if (-not (Test-Path $extractedLib -PathType Leaf)) {
      throw "Expected native library was not found in package: $RuntimePath"
    }

    New-Item -ItemType Directory -Path $TargetRoot -Force | Out-Null
    Copy-Item $extractedLib $TargetLib -Force
  }
  finally {
    Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
  }
}

switch ($Mode) {
  'local' { Install-FromLocal }
  'prebuilt' { Install-FromPrebuilt }
  'auto' { Install-FromPrebuilt }
  default { throw "Unsupported mode: $Mode" }
}

Write-Host "Installed: $TargetLib"
Write-Host 'Next: $env:SKIA_NATIVE_SOURCE = "prebuilt"'
Write-Host "Next: `$env:SKIA_PREBUILT_DIR = \"$TargetRoot\""
