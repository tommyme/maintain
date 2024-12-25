# powershell env setup

## scoop setup

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser 
irm get.scoop.sh | iex
```

## font setup 

[hack font download link](https://github.com/ryanoasis/nerd-fonts/releases/download/2.2.0-RC/Hack.zip)

## powershell setup

```powershell
# install some package
scoop install curl sudo jq neovim gcc fzf zoxide starship https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json
# or less package
scoop install sudo neovim starship https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json
```

```powershell
Install-Module posh-git -Scope CurrentUser -Force
Install-Module -Name Terminal-Icons -Repository PSGallery -Force
Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
Install-Module -Name PSFzf -Scope CurrentUser -Force
Install-Module -Name Recycle
```

here you need to restart `windows terminal` to make it.

in settings: set font to Hack NF and set whatever you like.

```powershell
mkdir ~\Documents\PowerShell
nvim $PROFILE       # it's  Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# . ~\maintain\powershell\user_profile.ps1

# if you need to use conda
conda init powershell
# and start a new powershell
```

## compile funciton Temporarily unavailable
