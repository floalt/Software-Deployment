﻿<#

    This script downloads current builds of KeePass Setup, Plugins and Language Files

    author: flo.alt@fa-netz.de
    https://github/floalt/
    version: 0.82

#>

## settings for invoke-scriptupdate

$scriptsrc = "https://raw.githubusercontent.com/floalt/Software-Deployment/main/keepass/keepass-download.ps1"


## activate TLS 1.1 and TLS 1.2

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]'Tls11,Tls12'
    
## getting script name & path and reading variables from config file:

    $scriptpath = (Split-Path -parent $PSCommandPath)
    $scriptname = $MyInvocation.MyCommand.Name
    $scriptfullpath = $scriptpath + "\" + $scriptname

    . $scriptpath\keepass-download.config.ps1


## --------------  functions  -------------- ##


function start-logfile {

    if (!(test-path $logpath)) {mkdir $logpath}
    $script:log_tempfile =  $logpath + "\" + $logname + "_log_tempfile" + ".log"
    $script:log_okfile = $logpath + "\" + $logname + "_ok" + ".log"
    $script:log_errorfile = $logpath + "\" + $logname + "_fail" + ".log"
    $script:log_today = $logpath + "\" + $logname + "-" + $(Get-Date -Format yyyyMMdd-HHmmss) + ".log"
    $script:log_clientfile = $logpath + "\" + "clientupdate" + ".log"
    "Beginning: $(Get-Date -Format yyyy-MM-dd_HH:mm:ss)" >> $log_tempfile
}



function close-logfile {

    "End: $(Get-Date -Format yyyy-MM-dd_HH:mm:ss)" >> $log_tempfile
    if ($log_today) {cp $log_tempfile $log_today}
    if ($errorcount -eq 0) {
        mv $log_tempfile $log_okfile -Force
        "Last update: $(Get-Date -Format yyyy-MM-dd_HH:mm:ss)" > $log_clientfile
    } else {
        mv $log_tempfile $log_errorfile -Force
    }
}



function start-scriptupdate {

    if ($autoupdate -eq 1) {
        $yeah="OK: Self-Update of this script successful"
        $shit="FAIL: Self-Update of this script failed"
        Invoke-WebRequest -Uri $scriptsrc -OutFile $scriptfullpath; errorcheck
    }

}


function remove-logfiles {

    [int]$Daysback = "-" + $logdays

    $CurrentDate = Get-Date
    $DatetoDelete = $CurrentDate.AddDays($Daysback)
    Get-ChildItem $logpath | Where-Object { ($_.Extension -eq ".log") -and ($_.LastWriteTime -lt $DatetoDelete) } | Remove-Item

}


function errorcheck {

    if ($?) {
        $yeah >> $log_tempfile
    } else {
        $shit >> $log_tempfile
        $script:errorcount = $script:errorcount + 1
    }
}


function dl-morefiles {
    foreach ($element in $dl_files) {

        $output = $dl_folder + "\" + $element.file

        $yeah="OK: Downloading " + $element.name + " successful"
        $shit="FAIL: Downloading " + $element.name + " failed"
        Invoke-WebRequest $element.url -Outfile $output; errorcheck
    }
}




## -------------- the script ist starting here -------------- ##


# first steps

    $dl_folder = $deploypath
    
    $logpath = $deploypath + "\logs"
    $logname = "keepass-download"
    $logdays = 21
    
    $errorcount = 0
    $timestamp = Get-Date -Format yyyy-MM-dd_HH:mm:ss

    start-logfile


# Downloading files

    dl-morefiles


# Unzip

        $yeah="OK: Unzip Plugins successful"
        $shit="FAIL: Unzip Plugins failed"
    Expand-Archive $deploypath\keepassfiles.zip $deploypath -Force; errorcheck
    rm $deploypath\keepassfiles.zip


# Finish

    start-scriptupdate
    close-logfile
    remove-logfiles
