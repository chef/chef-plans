#!/usr/bin/env powershell

#Requires -Version 5

param (
    [Parameter(Mandatory=$true,
    HelpMessage="Provide the name of the plan to verify.")]
    [ValidateNotNullorEmpty()]
    [string]$Plan
)

$env:HAB_ORIGIN = 'ci'

Write-Host "--- :8ball: :windows: Verifying $Plan"

$hab_minor_version = (hab --version).split('.')[1]
if ( -not $? -Or $hab_minor_version -lt 85 ) {
    Write-Host "--- :habicat: Installing the version of Habitat required"
    Install-Habitat --version 0.85.0.20190916
    if (-not $?) { throw "unable to install required version of Habitat"}
} else {
    Write-Host "--- :habicat: We have the version of Habitat required"
}

if (Test-Path -PathType leaf "/hab/cache/keys/ci-*.sig.key") {
    Write-Host "--- :key: Using existing fake '$env:HAB_ORIGIN' origin key"
} else {
    Write-Host "--- :key: Generating fake '$env:HAB_ORIGIN' origin key"
    hab origin key generate $env:HAB_ORIGIN
}

$project_root = "$(git rev-parse --show-toplevel)"
try {
  Set-Location $project_root

  Write-Host "--- :construction: Building $Plan"
  $env:DO_CHECK=$true; hab pkg build $Plan
  if (-not $?) { throw "unable to build" }

  . results/last_build.ps1
  if (-not $?) { throw "unable to determine details about this build"}

  Write-Host "--- :hammer_and_wrench: Installing $pkg_ident"
  hab pkg install results/$pkg_artifact
  if (-not $?) { throw "unable to install this build"}

  Write-Host "--- :mag_right: Testing $Plan"
  powershell -File "./${Plan}/tests/test.ps1" -PackageIdentifier $pkg_ident
} finally {
    Pop-Location
}