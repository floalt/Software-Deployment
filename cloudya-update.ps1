<#

    Install-Script for Update Cloudia via msi

    author: flo.alt@fa-netz.de
    https://github.com/floalt/gpo-scripts
    version: 0.6

#>


# Settings

    $software_name = "Cloudya"
    $search_name = "cloudya"
    $deploypath = "C:\install\cloudya"
    $logdir = "c:\install\cloudya\logs"
    $logfile = $logdir + "\install-" + (Get-Date -Format "yyyyMMdd") + ".log"
    $logcount = 30


# prepare logifile

    if (!(Test-Path $logdir)) {mkdir $logdir}
    $now = (Get-Date -Format "dd.MM.yyyy HH:mm:ss")
    Write-Output "`n---- Starting $now ----`n" >> $logfile

    # delete logfiles (keep $logcount files)

    Get-ChildItem $logdir -Filter *.log | Sort-Object LastWriteTime -Descending | Select-Object -Skip $logcount | Remove-Item -Force



# check, if software is already installed

    # search in x68 uninstall information
    $check = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -like "*$software_name*"}

    #search in x32 uninstall information
    if (!($check)) {

        $check = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -like "*$software_name*"}
        $installed_version = [version]$check.DisplayVersion
    }
    
        if (!$check) {

            # Software ist not installed => nothing to do.
            Write-Output "$software_name is not installed. Nothing to do. Exiting." >> $logfile
            exit 0
    
    } else {

        # set variable for installed version
        $installed_version = [version]$check.DisplayVersion
        Write-Output "INFO: Installed version is $installed_version" >> $logfile
    }

# check version of setup file

    $setup_file = Get-ChildItem -File $deploypath\* -Include $search_name*.msi | Sort-Object Name | select -Last 1
    
    $input_string = $setup_file.BaseName
    $regex_pattern = "\d+\.\d+\.\d+"

    if ($input_string -match $regex_pattern) {
        $version_string = $matches[0]

        # set variable for setupfile version
        $setup_version = [version]$version_string
        Write-Output "INFO: Setupfile version is $setup_version" >> $logfile
    } else {
        Write-Output "ERROR: Cannot extract version number from setup file string" >> $logfile
    }


# compare file versions

    if ($setup_version -gt $installed_version) {
        Write-Output "INFO: Setupfile is newer than installed version. Lets update..." >> $logfile
    } else {
        Write-Output "INFO: Installed version is up to date. Nothing to do. Exiting" >> $logfile
        exit 0
    }


# installing the software

$install = Start-Process "msiexec.exe" -ArgumentList "/i $setup_file /quiet" -Wait -PassThru
$exitCode = $install.ExitCode

if ($exitCode -eq 0) {
    Write-Output "OK: Update of $software_name $setup_version done successfully." >> $logfile
} else {
    Write-Output "FAIL: Something went wrong installing $software_name $setup_version. ExitCode: $exitCode" >> $logfile
}
