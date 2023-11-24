<#
description: Check setup-file for Version info.
    This script checks weather this info is available or not and
    promts for version-info in that case

author: flo.alt@fa-netz.de
version: 0.8

#>


## getting script name & path and reading variables from config file:

    $scriptpath = (Split-Path -parent $PSCommandPath)
    $scriptname = $MyInvocation.MyCommand.Name
    $scriptfullpath = $scriptpath + "\" + $scriptname



### -------- setup --------

# settings for invoke-scriptupdate
$scriptsrc = "https://raw.githubusercontent.com/floalt/Software-Deployment/main/keepass-download.ps1"  ### URL ist falsch!

# load config file
. $scriptpath\config.ps1


###   -------- finish setup --------


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

# update this script itself by Github source
Invoke-WebRequest -Uri $scriptsrc -OutFile $scriptfullpath