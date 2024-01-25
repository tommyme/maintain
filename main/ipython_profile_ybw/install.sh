suffix="ybw" # 要和文件夹(ipython_profile_ybw)的后缀保持一致
profile_root="$HOME/.ipython/profile_$suffix"
startup="$HOME/.ipython/profile_$suffix/startup"
root="$HOME/maintain/main/ipython_profile_$suffix"
mkdir $profile_root
mkdir $startup
ln -sf "$root/ipython_config.py" "$profile_root/" 
ln -sf "$root/rc.py" "$startup/"
echo "over." 
