# Habitat package: ruby27-plus-devkit

This is a repackaging of the MSYS2 based RubyInstaller2 for Windows. Packages produced with this plan will include the MSYS2 "DevKit" to provide libraries and binaries that the Ruby ecosystem tends to rely upon.

## Type of Package

Binary package

## Usage

This package provides binaries and libraries specifically for consumption by Ruby-based projects from Chef Software. No support should be expected for direct use of this package by other projects.

For Chef projects on Windows:

* Add this to your package's runtime dependencies. `$pkg_deps=@("chef/ruby27-plus-devkit")`
* Your package likely installs gems it requires. Those gems should be installed them to a directory within your project. Push that package-internal directory onto GEM_PATH.

## Testing

Build the package and run tests, from this plan directory:

```
hab pkg build .
. results/last_build.ps1
./test.ps1 -PackageIdentifier $pkg_ident
```
