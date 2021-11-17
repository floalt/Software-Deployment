<#

    Install-Script for Teamviewer Deployment

    author: flo.alt@fa-netz.de
    https://github.com/floalt/gpo-scripts
    version: 0.7

#>


# Settings

$software_name = "TeamViewer Host"
$software_version = "15.15.5"
$setup = "\\serv12-dc\deployment\teamviewer\TeamViewer_Host_Setup.exe"


# checking installation & version

$check = Get-Package -Provider Programs | where {$_.Name -like "*$software_name*"}

if ($check.Name -ne $software_name) {
    echo "Wrong Teamviewer Edition. Exiting"
    exit 0
}

if ($check.Version -ge $software_version) {
    echo "This Verision or newer already installed"
    exit 0
}


# installing the software

&$setup /S