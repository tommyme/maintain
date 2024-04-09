```powershell
# for preview
copy your setting to ~\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState
```

- 也可以创建符号链接
不要打开wt(wt运行的时候配置文件删不掉 换不掉) 打开原生powershell7 执行下面的命令
```powershell
rm "$home\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
sudo New-Item -ItemType SymbolicLink -Path "$home\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json" -Target "$home\maintain\main\windows terminal\settings.json"
```
