param(
    [Parameter()]
    [string]$PackageIdentifier = $(throw "Usage: test.ps1 [test_pkg_ident] e.g. test.ps1 ci/user-windows-default/1.0.0/20190812103929")
)

$PackageVersion = $PackageIdentifier.split('/')[2]

Describe "ruby-plus-devkit" {
    Context "ruby" {
        It "is an executable" {
            hab pkg exec $PackageIdentifier ruby.exe --version
            $? | Should be $true
        }

        It "is the expected version" {
            $version_output = (hab pkg exec $PackageIdentifier ruby.exe --version | Out-String)
            $version_output | Should MatchExactly "ruby ${PackageVersion}p"
        }
    }

    Context "gem" {
        It "is an executable" {
            hab pkg exec $PackageIdentifier gem.cmd --version
            $? | Should be $true
        }
    }

    Context "bundle" {
        It "is an executable" {
            hab pkg exec $PackageIdentifier bundle.cmd --version
            $? | Should be $true
        }
    }

    Context "setup environment paths" {
        $PackagePath = (hab pkg path $PackageIdentifier)
        It "pushes its gems onto GEM_PATH" {
            "${PackagePath}/RUNTIME_ENVIRONMENT" | Should ContainExactly "GEM_PATH"
        }
        It "does not include build studio kruft in paths" {
            "${PackagePath}/RUNTIME_ENVIRONMENT" | Should not ContainExactly "\\hab\\studios"
        }
    }
}