<#

    This script downloads current builds of KeePass Setup, Plugins and Language Files

    author: flo.alt@fa-netz.de
    https://github/floalt/
    version: 0.71

#>

## configure some things:

$deploypath = "\\serv-dc\deployment\keepass"
$dl_folder = $deploypath
$dl_files = @(
    @{name = 'KeePass Setup';url = 'https://doku.fa-netz.de/downloads/KeePass-Setup.exe'}
    @{name = 'KeePass Plugins';url = 'https://doku.fa-netz.de/downloads/keepassfiles.zip'}
)


## functions

function errorcheck {
    if ($?) {
        write-host $yeah -F Green
    } else {
        write-host $shit -F Red
        $script:errorcount = $script:errorcount + 1
    }
}


function dl-morefiles {
    foreach ($file in $dl_files) {
        $yeah="OK: Downloading " + $file.name + " successful"
        $shit="FAIL: Downloading " + $file.name + " failed"
        Start-BitsTransfer $file.url $dl_folder; errorcheck
    }
}


## the script ist starting here

$errorcount = 0
$timestamp = Get-Date -Format yyyy-MM-dd_HH:mm:ss


# Downloading files

dl-morefiles

# Unzip
    $yeah="Unzip Plugins successful"
    $shit="Unzip Plugins failed"
Expand-Archive $deploypath\keepassfiles.zip $deploypath -Force; errorcheck
rm $deploypath\keepassfiles.zip

# Finish
if ($errorcount -eq 0) {
    $timestamp > $deploypath\lastgooddownload.txt 
} else {
    $timestamp > $deploypath\lastbaddownload.txt 
}