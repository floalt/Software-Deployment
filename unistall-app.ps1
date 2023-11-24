# description: Uninstall Software
# author: flo.alt@fa-netz.de
# version: 0.5


$mysoftware = "My Software"

# check if $mysoftware in installed

$check_inst = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -like "$mysoftware*"}
if (!$check_inst) {
    Write-Host "$mysoftware is not installed. Exiting."
    exit 0
}

# unistall

Write-Host "Removing $mysoftware"
$removeme = Get-WmiObject -Class Win32_Product | where {$_.Name -like "$mysoftware*"}
$removeme.Uninstall()
