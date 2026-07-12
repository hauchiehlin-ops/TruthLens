param(
  [string]$Generator = "Visual Studio 17 2022",
  [string]$Arch = "x64",
  [string]$Config = "Release"
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $ScriptDir "..\..")
$LibsDir = Join-Path $RepoRoot "windows\libs"
$LlamaDir = Join-Path $ScriptDir "llama.cpp"
$BuildDir = Join-Path $ScriptDir "build-windows-$Arch"

if (!(Test-Path $LlamaDir)) {
  Write-Host "-> clone llama.cpp ..."
  git clone --depth 1 https://github.com/ggml-org/llama.cpp.git $LlamaDir
}

Write-Host "-> cmake configure Windows $Arch ..."
cmake -S $ScriptDir -B $BuildDir -G $Generator -A $Arch `
  -DCMAKE_BUILD_TYPE=$Config `
  -DGGML_VULKAN=OFF `
  -DGGML_CUDA=OFF `
  -DGGML_BLAS=OFF

Write-Host "-> cmake build Windows $Arch ..."
cmake --build $BuildDir --target truthlens_llama --config $Config

New-Item -ItemType Directory -Force -Path $LibsDir | Out-Null

$Candidates = @(
  (Join-Path $BuildDir "$Config\truthlens_llama.dll"),
  (Join-Path $BuildDir "bin\$Config\llama.dll"),
  (Join-Path $BuildDir "bin\$Config\ggml.dll"),
  (Join-Path $BuildDir "bin\$Config\ggml-base.dll"),
  (Join-Path $BuildDir "bin\$Config\ggml-cpu.dll")
)

foreach ($File in $Candidates) {
  if (Test-Path $File) {
    Copy-Item $File $LibsDir -Force
  } else {
    Write-Warning "Missing expected DLL: $File"
  }
}

Write-Host "Done. windows\libs contains:"
Get-ChildItem $LibsDir -Filter *.dll | Select-Object -ExpandProperty Name
