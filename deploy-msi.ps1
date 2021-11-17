<#

    Install-Script for MSI Deployment via GPO

    author: flo.alt@fa-netz.de
    https://github.com/floalt/gpo-scripts
    version: 0.6

#>


# Settings

$software_name = "mysoftware"
$setup = "\\serv-dc\deployment\mysoftware\setup.msi"


# check, if software is already installed

$check = Get-Package -Provider Programs | where {$_.Name -like "*$software_name*"}
if (!$check) {
    $check = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -like "*$software_name*"}
    if (!$check) {
        $check = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -like "*$software_name*"}
    }
}

if ($check) {
    echo "$software_name is already installed. Exiting."
    exit 0
}

# installing the software

msiexec.exe /i $setup /quiet