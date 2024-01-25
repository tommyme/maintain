$suffix = "ybw"
$profile_root = "$env:USERPROFILE\.ipython\profile_$suffix"
$startup = "$profile_root\startup"
$root = "$env:USERPROFILE\maintain\ipython_profile_$suffix"
mkdir -Force -Path $profile_root
mkdir -Force -Path $startup
