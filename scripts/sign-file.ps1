# Custom Windows code-signing command, referenced by `bundle.windows.signCommand`
# in src-tauri/tauri.compat.conf.json. Signs the given binary with Azure
# Trusted Signing when the following environment variables are present
# (wire them up as repository secrets in .github/workflows/build-compat.yml):
#
#   AZURE_SIGNING_ENDPOINT           Trusted Signing account endpoint, e.g. https://eus.codesigning.azure.net/
#   AZURE_SIGNING_ACCOUNT_NAME       Trusted Signing account name
#   AZURE_SIGNING_CERT_PROFILE_NAME  Public Trust certificate profile name
#   AZURE_TENANT_ID                  Entra tenant id (read by the Dlib's DefaultAzureCredential)
#   AZURE_CLIENT_ID                  Entra app registration client id
#   AZURE_CLIENT_SECRET              Entra app registration client secret
#
# When any of them is missing the script exits 0 without touching the file,
# so local builds and CI without signing secrets keep producing unsigned
# installers exactly as before.

param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string] $Path
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$endpoint = $env:AZURE_SIGNING_ENDPOINT
$account = $env:AZURE_SIGNING_ACCOUNT_NAME
$certProfile = $env:AZURE_SIGNING_CERT_PROFILE_NAME

if (-not $endpoint -or -not $account -or -not $certProfile) {
  Write-Host "[sign-file] AZURE_SIGNING_* env not configured, skipping signature for: $Path"
  exit 0
}

function Find-SignTool {
  if ($env:TAURI_WINDOWS_SIGNTOOL_PATH -and (Test-Path $env:TAURI_WINDOWS_SIGNTOOL_PATH)) {
    return $env:TAURI_WINDOWS_SIGNTOOL_PATH
  }
  foreach ($regPath in @(
    'HKLM:\SOFTWARE\Microsoft\Windows Kits\Installed Roots',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows Kits\Installed Roots'
  )) {
    try {
      $kitsRoot = (Get-ItemProperty $regPath -ErrorAction Stop).KitsRoot10
      $kits = Get-ChildItem -Directory (Join-Path $kitsRoot 'bin') -ErrorAction Stop |
        Sort-Object Name -Descending
      foreach ($kit in $kits) {
        $candidate = Join-Path $kit.FullName 'x64\signtool.exe'
        if (Test-Path $candidate) { return $candidate }
      }
    } catch { continue }
  }
  $cmd = Get-Command signtool.exe -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  return $null
}

$signtool = Find-SignTool
if (-not $signtool) {
  Write-Error '[sign-file] signtool.exe not found; install the Windows SDK or set TAURI_WINDOWS_SIGNTOOL_PATH'
  exit 1
}

# Fetch (and cache in the temp dir) the Trusted Signing Dlib from NuGet.
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
$version = $env:TRUSTED_SIGNING_CLIENT_VERSION
if (-not $version) {
  $index = Invoke-RestMethod 'https://api.nuget.org/v3-flatcontainer/microsoft.trusted.signing.client/index.json'
  $version = $index.versions | Where-Object { $_ -notmatch '-' } | Select-Object -Last 1
}
$dlibDir = Join-Path ([IO.Path]::GetTempPath()) "ts-signing\$version"
$extracted = Join-Path $dlibDir 'package.extracted'
if (-not (Test-Path $extracted)) {
  New-Item -ItemType Directory -Force -Path $extracted | Out-Null
  $nupkg = Join-Path $dlibDir 'package.zip'
  Invoke-WebRequest "https://api.nuget.org/v3-flatcontainer/microsoft.trusted.signing.client/$version/microsoft.trusted.signing.client.$version.nupkg" -OutFile $nupkg
  Expand-Archive -Path $nupkg -DestinationPath $extracted -Force
}
$dlib = Get-ChildItem $extracted -Recurse -Filter 'Azure.CodeSigning.Dlib.dll' | Select-Object -First 1
if (-not $dlib) {
  Write-Error "[sign-file] Azure.CodeSigning.Dlib.dll not found in Microsoft.Trusted.Signing.Client $version"
  exit 1
}

$metaPath = Join-Path ([IO.Path]::GetTempPath()) 'ts-signing-metadata.json'
[ordered]@{
  Endpoint = $endpoint
  CodeSigningAccountName = $account
  CertificateProfileName = $certProfile
} | ConvertTo-Json | Set-Content -Path $metaPath -Encoding ascii

Write-Host "[sign-file] signing $Path via Azure Trusted Signing ($account/$certProfile)"
& $signtool sign /fd SHA256 /dlib $dlib.FullName /dmdf $metaPath $Path
exit $LASTEXITCODE
