<#
    config file for keepass-download.ps1
#>

# Set the path, where all the action takes place.

    $deploypath = "\\serv19-dc\deployment\keepass"


# set the files to be downloaded 

    $dl_files = @(
        @{name = 'KeePass Setup';url = 'https://doku.fa-netz.de/downloads/KeePass-Setup.exe'; file = 'KeePass-Setup.exe'}
        @{name = 'KeePass Plugins';url = 'https://doku.fa-netz.de/downloads/keepassfiles.zip'; file = 'keepassfiles.zip'}
    )


# set auto-update for this script
# if value = 1, this script updates itself by using source on GitHub

    $autoupdate = 1