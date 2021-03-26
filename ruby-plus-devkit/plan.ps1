$pkg_name="ruby-plus-devkit"
$pkg_origin="chef"
$pkg_version="2.6.6"
$pkg_revision="2"
$pkg_description="A repackaging of RubyInstaller2 and its MSYS2-based DevKit."
$pkg_maintainer="The Chef Maintainers <maintainers@chef.io>"
$pkg_upstream_url="https://github.com/chef/chef-plans"
$pkg_license=@("Apache-2.0")
$pkg_source="https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-${pkg_version}-${pkg_revision}/rubyinstaller-devkit-${pkg_version}-${pkg_revision}-x64.exe"
$pkg_shasum="678fb941c75bdc0fed902e78d5e984410c0b166a53cd3a0b036046ceace91f47"
$pkg_bin_dirs=@(
    "bin"
    "/msys64/mingw64/bin"
    "/msys64/usr/bin"
)
$ruby_abi_version = [RegEx]::Replace($pkg_version, "\.\d+$", ".0")

function Invoke-SetupEnvironment {
    Push-RuntimeEnv -IsPath "GEM_PATH" "$pkg_prefix/lib/ruby/gems/$ruby_abi_version"
}

function Invoke-Unpack {
    Write-BuildLine "Unpacking $pkg_filename"
    Start-Process "$HAB_CACHE_SRC_PATH/$pkg_filename" -Wait -ArgumentList "/SP- /NORESTART /VERYSILENT /SUPPRESSMSGBOXES /NOPATH /DIR=$HAB_CACHE_SRC_PATH/$pkg_dirname"
}

function Invoke-Build {
    Write-BuildLine "** Launch msys2 once in order to initialize the install"
    Start-Process "$HAB_CACHE_SRC_PATH/$pkg_dirname/msys64/msys2_shell.cmd" -ArgumentList "-defterm -no-start"
    # The path separator in the -ILike value below must be a backslash for it will match properly
    Get-Process | Where-Object Path -ILike "$HAB_CACHE_SRC_PATH\$pkg_dirname\*" | Stop-Process -Force
}

function Invoke-Install {
    Write-BuildLine "** Copying files to the package location"
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/*" "$pkg_prefix" -Recurse -Force

    Write-BuildLine "** Include git because why not at this point."
    Invoke-Expression -Command "$pkg_prefix/bin/ridk.cmd exec pacman -S --noconfirm git" -Verbose
}

function Invoke-After {
    Write-BuildLine "** Clean-up unnecessary cached items"
    Get-ChildItem $pkg_prefix/lib/ruby/gems/$ruby_abi_version/gems -Filter "spec" -Recurse | Remove-Item -Recurse -Force
    Get-ChildItem $pkg_prefix/lib/ruby/gems/$ruby_abi_version/cache -Recurse | Remove-Item -Recurse -Force
    Get-ChildItem $pkg_prefix -Filter "unins000.*" | Remove-Item -Recurse -Force
    Get-ChildItem $pkg_prefix -Filter "share" | Remove-Item -Recurse -Force
}

function Invoke-End {
    Write-BuildLine "** Remove RubyInstaller installer from system state"
    Start-Process "$HAB_CACHE_SRC_PATH/$pkg_dirname/unins000.exe" -Wait -ArgumentList "/SILENT /NORESTART"
}
