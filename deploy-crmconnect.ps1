<#
    
    installs software like this
        1. downloads setup-file
        2. installs software
    
    This script can be downloaded and started via ESET Remote Administrator:
        c:\windows\system32\windowspowershell\v1.0\powershell.exe wget https://doku.fa-netz.de/downloads/deploy-crmconnect.ps1 -OutFile C:\Windows\Temp\deploy-crmconnect.ps1
        c:\windows\system32\windowspowershell\v1.0\powershell.exe C:\Windows\Temp\deploy-crmconnect.ps1
    
    author: flo.alt@fa-netz.de
    https://github/floalt/
    version: 0.5

#>


$app_name = "CRM Connect"
$search_name = "CRM Connect"
$url = "https://doku.fa-netz.de/downloads/crm.exe"
$setup_file = "crm.exe"
$workdir = "c:\install\"

$setup_param_exe = "/S"
$setup_param_msi = ""

$logpath = "\\serv-dc\deployment\logs\crmconnect\"
$logname = "crm-install"


# --------- functions --------- #

function dl-file {

    $dl_folder = $workdir
    $dl_name = "$app_name"

    $yeah="OK: Downloading $dl_name successful"
    $shit="FAIL: Downloading $dl_name failed"
    Start-BitsTransfer $url $dl_folder; errorcheck
}


function install-app {

    $deploypath = "$workdir"
    $setup = $deploypath + $setup_file

    "OK: Starting installation of $app_name..." >> $log_tempfile
    $ext = (Get-Item $setup).extension
        
    $yeah = "OK: Starting to install $app_name $setup_version successfully."
    $shit = "FAIL: Installing $app_name $setup_version failed"
    
    # installing exe file

    if ($ext -eq ".exe") {
        if ($setup_param_exe -eq "") {
            Start-Process $setup -Wait
            errorcheck
        } else {
            Start-Process $setup -Wait -ArgumentList $setup_param_exe
            errorcheck
        }

    # installing msi file
    
    } elseif ($ext -eq ".msi") {
        if ($setup_param_msi -eq "") {
            Start-Process msiexec.exe -Wait -ArgumentList "/passive /i $setup"
            errorcheck
        } else {
            Start-Process msiexec.exe -Wait -ArgumentList "/passive /i $setup $setup_param_msi"
            errorcheck
        }
    
    # fail if neither exe nor msi
    
    } else {
            "FAIL: setup file has no vaild extension (exe or msi)" >> $log_tempfile
            $script:errorcount = $script:errorcount + 1
        }
    
    errorcheck-app
}



function errorcheck-app {
    
    $installed_version = ""
    $installed_version = (get-version-app)

    if ($installed_version) {
        "OK: $app_name is installed successfully." >> $log_tempfile
    } else {
        "FAIL: $app_name could not be installed." >> $log_tempfile
        $script:errorcount = $script:errorcount + 1
        $script:instfail = $script:instfail +1
    }
}


function get-version-app {
    
    # first check registry for 64bit software
        $version = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | ? DisplayName -like "*$search_name").DisplayVersion

    # then check registry for 32bit software
        if (!$version) {
            $version = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | ? DisplayName -like "*$search_name").DisplayVersion
        }
    
    # last try this way:
        if (!$version) {
            $version = (Get-Package -Provider Programs | where {$_.Name -like "*$search_name"}).Version
        }

    return $version
}


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

# --------- end functions --------- #


# --------- here it begins --------- #

$errorcount = 0
$instfail = 0

if (!(test-path $workdir)) {mkdir $workdir}
start-logfile

dl-file
install-app

end-logfile
