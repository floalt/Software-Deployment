<#

    This script updates KeePass Application (only)
    
    author: flo.alt@fa-netz.de
    https://github/floalt/
    version: 0.7

#>

## configure some things:

$deploypath = "\\serv-dc\deployment\keepass"
$setupfile = "KeePass-Setup.exe"
$setup_param = "/VERYSILENT"
$app_name = "KeePass"

$logpath = "\\serv-dc\deployment\logs\keepass\"
$logname= "$app_name"


## functions

function errorcheck {
    if ($?) {
        $yeah >> $log_tempfile
    } else {
        $shit >> $log_tempfile
        $script:errorcount = $script:errorcount + 1
    }
}

function start-logfile {
    if (!(test-path $logpath)) {mkdir $logpath}
    $script:log_tempfile =  "C:\" + $logname + "_log_tempfile" + ".log"
    $script:log_okfile = $logpath + "ok_" + $env:COMPUTERNAME + ".log"
    $script:log_errorfile = $logpath + "fail_" + $env:COMPUTERNAME + ".log"
    "Beginning: $(Get-Date -Format yyyy-MM-dd_HH:mm:ss)" >> $log_tempfile
}

function end-logfile {
    "End: $(Get-Date -Format yyyy-MM-dd_HH:mm:ss)" >> $log_tempfile
    if ($errorcount -eq 0) {
        mv $log_tempfile $log_okfile -Force
    } else {
        mv $log_tempfile $log_errorfile -Force
    }
}

function check-versions {
    $script:setup_version = $null
    $script:installed_version = $null
    [version]$script:setup_version = (Get-ChildItem $deploypath\$setupfile).VersionInfo.ProductVersion
    "INFO: Version to install: $setup_version" >> $log_tempfile
    [version]$script:installed_version = (Get-Package -Provider Programs | where {$_.Name -like "$app_name*"}).Version
    "INFO: Installed version: $installed_version" >> $log_tempfile
}


function install-app_exe {
    $yeah = "OK: Installing $app_name $setup_version done successfully."
    $shit = "FAIL: Installing $app_name $setup_version failed"
    Start-Process $deploypath\$setupfile -Wait -ArgumentList $setup_param; errorcheck
}


function do-update {
    if ($installed_version -lt $setup_version) {
        "INFO: Update for $app_name available. Performing Update..." >> $log_tempfile
        install-app_exe
    } else {
        "INFO: $app_name ist uptodate: $setup_version Skipping Update" >> $log_tempfile
    }
}



## the script ist starting here

$errorcount = 0
start-logfile

check-versions

if ($script:installed_version -eq $null) {
    "INFO: $app_name is not installed. Nothing to do." >> $log_tempfile
    sleep 1
} else {
    do-update
}

# finnishing

end-logfile