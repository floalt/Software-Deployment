<#
config file for update-anything.ps1 and check-setupfile.ps1
#>

$app_name = "Nextcloud Client"
$search_name = "Nextcloud"
$deploypath = "\\[domain].local\shared\deployment\nextcloud\"
$setup_param_exe = "/S"
$setup_param_msi = "REBOOT=ReallySuppress"

$logpath = "\\[domain].local\shared\deployment\logs\nextcloud\"
$logname = "ncupdate"

$autoupdate = 1