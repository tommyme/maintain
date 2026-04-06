# PowerShell Environment Setup

## Scoop Setup

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex
```

## Font Setup

[Hack Nerd Font download](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip)

## Scoop Packages

```powershell
scoop install sudo neovim fzf zoxide starship yazi
```

## PowerShell Modules

```powershell
Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
Install-Module -Name PSFzf -Scope CurrentUser -Force
```

## Windows Terminal Setup

Set font to Hack Nerd Font in terminal settings.

```powershell
mkdir ~/Documents/PowerShell
nvim $PROFILE   # opens Documents\PowerShell\Microsoft.PowerShell_profile.ps1

# Link user profile
# . ~/maintain/powershell/user_profile.ps1
```

## Conda (optional)

```powershell
conda init powershell
# restart terminal after
```

## Directory Structure

```
powershell/
├── user_profile.ps1    # main config (starship, zoxide, PSReadLine, psfzf)
├── custom/             # custom scripts (auto-loaded)
│   └── *.ps1           # files here are auto-sourced
└── module/
    └── git.ps1         # git helpers (gcmsg, gco, gcb, grv, gba, gb, gp, gaa)
```

## Custom Extensions

Drop `.ps1` files under `powershell/custom/` and they will be auto-loaded.
