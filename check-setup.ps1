<#
description: Check setup-file for Nextcloud Client
    If there is no version-info implemented in the setup-file
    the install-nextcloud.ps1 script cannot perfon installation
    This script checks weather this info is available or not and
    promts for version-info in that case

author: flo.alt@fa-netz.de
version: 0.61

#>

# setup here:
$deploypath = "\\serv12-dc\deployment\nextcloud\"

# look for most recent setup file:
$setup_fileinfo = Get-ChildItem -File $deploypath\* -Include $search_name*.exe, $search_name*.msi | Sort-Object Name | select -Last 1
$version = $setup_fileinfo.VersionInfo.FileVersion

# check if version info is there and if not ask for it
if (!$version) {
    write-host "There is no version info implemented in the setup-file"
    $man_version = Read-Host "Please enter version number manually: "
    }
else {
    write-host "Everything OK: The version info implemented in the setup-file is: $version"
    pause
    exit 0
}

# write version info to txt file
$output_file = $deploypath + $setup_fileinfo.BaseName + ".version"
$man_version > $output_file
write-host "You entered version info: $man_version"
write-host "written to file $output_file"
pause