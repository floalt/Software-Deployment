<#

    This script downloads current builds of KeePass Setup, Plugins and Language Files

    author: flo.alt@fa-netz.de
    https://github/floalt/
    version: 0.8

#>


# reading variables from config file:

$scriptpath = (Split-Path -parent $PSCommandPath)
. $scriptpath\keepass-download.config.ps1


## --------------  functions  -------------- ##


function start-logfile {

    if (!(test-path $logpath)) {mkdir $logpath}
    $script:log_tempfile =  $logpath + "\" + $logname + "_log_tempfile" + ".log"
    $script:log_okfile = $logpath + "\" + $logname + "_ok" + ".log"
    $script:log_errorfile = $logpath + "\" + $logname + "_fail" + ".log"
    $script:log_today = $logpath + "\" + $logname + "-" + $(Get-Date -Format yyyyMMdd-HHmmss) + ".log"
    "Beginning: $(Get-Date -Format yyyy-MM-dd_HH:mm:ss)" >> $log_tempfile
}



function close-logfile {

    "End: $(Get-Date -Format yyyy-MM-dd_HH:mm:ss)" >> $log_tempfile
    if ($log_today) {cp $log_tempfile $log_today}
    if ($errorcount -eq 0) {
        mv $log_tempfile $log_okfile -Force
    } else {
        mv $log_tempfile $log_errorfile -Force
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

    close-logfile
    remove-logfiles