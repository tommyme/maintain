suffix="ybw" # 要和文件夹(ipython_profile_ybw)的后缀保持一致
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
profile_root="$HOME/.ipython/profile_$suffix"
startup="$HOME/.ipython/profile_$suffix/startup"
mkdir -p $profile_root
mkdir -p $startup
ln -sf "$SCRIPT_DIR/ipython_config.py" "$profile_root/" 
ln -sf "$SCRIPT_DIR/rc.py" "$startup/"
echo "over. please use < ipython --profile=name > to start" 
