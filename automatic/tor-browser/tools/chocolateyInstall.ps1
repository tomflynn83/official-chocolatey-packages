$packageName = 'tor-browser'
$installerType = 'exe'
$installArgs = '/S'
$url32 = ''
$checksum32 = ''

# binRoot is only for compatibility reasons.
# will be removed from future releases
$binRoot = Get-BinRoot
$destinationFolder = Join-Path $binRoot 'tor-browser'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

if (!(Test-Path $destinationFolder)) {
  $destinationFolder =  Join-Path $toolsDir 'tor-browser'
} else {
  Write-Output $(
    'Deprecated installation folder detected (binRoot). ' +
    'This package will continue to install tor-browser there ' +
    'unless you manuall remove if from "' + $destinationFolder + '".'
  )
}

$pathDownloadedInstaller = Join-Path $env:TEMP 'tor-browserInstall.exe'

$desktopPath = $([Environment]::GetFolderPath('Desktop'))
$oldDestinationFolder = Join-Path $desktopPath 'Tor Browser'

if ((Test-Path $oldDestinationFolder) -and
  ($oldDestinationFolder -ne $destinationFolder)) {

  $destinationFolder = $oldDestinationFolder

Write-Output @"
Warning: Deprecated installation folder detected: Desktop/Tor Browser.
This package will continue to install tor-browser there unless you
remove the deprecated installation folder. After you did that, reinstall
this package again with the “-force” parameter. Then it will use
%ChocolateyBinRoot%\tor-browser.
"@
}


$language = (Get-Culture).Name -replace '-[a-z]{2}', '' # get language code
#$language = 'xx' # Language override for testing

$table = @{
  'en' = 'en-US';
  'ar' = 'ar';
  'de' = 'de';
  'es' = 'es-ES';
  'fa' = 'fa';
  'fr' = 'fr';
  'it' = 'it';
  'ko' = 'ko';
  'nl' = 'nl';
  'pl' = 'pl';
  'pt' = 'pt-PT';
  'ru' = 'ru';
  'tr' = 'tr';
  'vi' = 'vi';
  'zh' = 'zh-CN';
}

$langcode = $table[$language]
# English = fallback language
if ($langcode -eq $null) {$langcode = 'en-US'}

$url = $url32.Replace("en-US", $langcode)

$packageArgs = @{
  PackageName = $packageName 
  FileFullPath = $pathDownloadedInstaller 
  Url = $url
  Checksum = $checksum32
  ChecksumType = 'sha256'
}
Get-ChocolateyWebFile @packageArgs

Start-Process -Wait $pathDownloadedInstaller -ArgumentList '/S', "/D=$destinationFolder"

Remove-Item $pathDownloadedInstaller

# Create .ignore files for exe’s
Get-ChildItem -Path $destinationFolder -Recurse | Where {
  $_.Extension -eq '.exe'} | % {
  New-Item $($_.FullName + '.ignore') -Force -ItemType file
# Suppress output of New-Item
} | Out-Null
