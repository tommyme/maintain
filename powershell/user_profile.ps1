# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

. ~/maintain/powershell/module/git.ps1
# Env
# $env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"
# $env:PATH = "C:\Program Files\Git\usr\bin;"+$env:PATH   # use gnu utils
# $env:PATH = "$home\tools;"+$env:PATH   # use gnu utils
# Measure-Command {   # 509
#   Import-Module posh-git
#   $omp_config = Join-Path $PSScriptRoot ".\takuya.omp.json"
#   oh-my-posh init pwsh --config $omp_config | Invoke-Expression
# }

# Measure-Command {   # 214
#   Import-Module -Name Terminal-Icons
# }
Invoke-Expression (&starship init powershell)

# PSReadLine
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadlineKeyHandler -Key Tab -Function Complete
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Measure-Command {   # 109
#   # Fzf
#   Import-Module PSFzf
#   Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
# }



# Alias

Set-Alias alias Set-Alias
alias g git
alias grep findstr
alias p3 python
function p3p(){
  python -m pip $args
}
function python3(){
  python $args
}
alias new New-Item
alias -Name vim -Value nvim
alias ll ls
alias g git
function gitback(){
  git reset . && git checkout . && git clean -df $args
}
function gco(){
  git checkout $args
}
function gcb(){
  git checkout xxx $args
}
function grv(){
  git remote -v $args
}
alias grep findstr
alias tig 'C:\Program Files\Git\usr\bin\tig.exe'
alias less 'C:\Program Files\Git\usr\bin\less.exe'
function j() {
  Push-Location
  z @args
}
function ofd(){
  explorer .
}
function i(){
  ipython --profile=ybw $args
}
function ca(){
  conda activate @args
}
function cda(){
  conda deactivate @args
}
Remove-Alias md
Remove-Alias del
Remove-Alias grep
alias md "C:\Program Files\Typora\Typora.exe"
alias del Remove-ItemSafely

function ahk(){
  sudo ~/maintain/main/ahk/test.ahk $args
}

function pon($url, $ssl) {
  $env:http_proxy="http://"+$url
  $https_prefix= if ($ssl) { "https://" } else { "http://" }
  $env:https_proxy=$https_prefix+$url
  $env:HTTP_PROXY=$env:http_proxy
  $env:HTTPS_PROXY=$env:https_proxy
}

function poff() {
  $env:http_proxy=''
  $env:https_proxy=''
  $env:HTTP_PROXY=''
  $env:HTTPS_PROXY=''
}
# Utilities
function which ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function pypath() {
  $env:PYTHONPATH = $(pwd).ToString()+";"+$env:PYTHONPATH
}
function pyp() {
    if (-not $env:PYTHONPATH) {
        $env:PYTHONPATH = $args[0]
    } else {
        $x = $args[0]
        $env:PYTHONPATH = "$x;$env:PYTHONPATH"
    }
}
function pypc() {
  echo $env:PYTHONPATH
}
function pypwd() {
  $x = pwd
  pyp $x
}
function pypclr() {
  $env:PYTHONPATH = ""
}

function ims {
  $output = & "aimswitcher" "--imm"
  if ($output -eq "1025") {
    & "aimswitcher" "--imm" "0"
  } else {
    & "aimswitcher" "--imm" "1025"
  }
}

function conda-init {
  (& "$home\miniconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | Invoke-Expression
}

$customPs1Path = "~\maintain\powershell\custom"
if (Test-Path $customPs1Path) {  
  Get-ChildItem -Path $customPs1Path -Filter *.ps1 | ForEach-Object { . $_.FullName }
} 

function psh {
  # generated by monica, origin script is written in python, rewrite in pwsh script.
  $command = $args[0]

  $env:PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [Environment]::GetEnvironmentVariable("PATH", "User")

  $py_scripts = @()
  $flag = $false

  function judge($path) {
      try {
          $content = Get-Content $path -Raw
      } catch {
          return $false
      }
      $header = $content.Split("`n")[0].Trim()
      if ($header.StartsWith("#!") -and ($header.EndsWith("python3") -or $header.EndsWith("python"))) {
          return $true
      }
      return $false
  }
  $final_path = ""
  foreach ($p in $env:PATH.Split(";")) {
      if (-not $p) {
        continue
      }
      $pp = Join-Path $p $command
      if (Test-Path $pp -PathType Leaf) {
        if (judge $pp) {
            $flag = $true
            $final_path = $pp
        }
      }
  }
  if ($flag) {
    $xargs = $args[1..($args.Length - 1)]
    python3 $final_path @xargs
  } else {
    echo "command not found"
  }

}

function gii($lang) {
  # gi 被系统占用了
    $uri = "https://www.gitignore.io/api/$lang"
    Invoke-RestMethod -Method Get -Uri $uri
}

Remove-Alias cd
function cd {
  param(
    [string]$path = $null
  )
  Push-Location && Set-Location $path
}
function d() {
  cd ..
}
function dd() {
  cd ..\..
}
function ddd() {
  cd ..\..\..
}
function dddd() {
  cd ..\..\..\..
}
function o() {
  psh o @args
}
Remove-Alias popd
alias popd Pop-Location

function netconf {
    [CmdletBinding()]
    param(
        [string]$ipAddress,
        [string]$gateway,
        [string]$dnsServer,
        [switch]$reset
    )

    $adapterName = (Get-NetAdapter).Name[1]

    if ($reset) {
        # 恢复默认网络设置
        sudo Remove-NetIPAddress -InterfaceAlias $adapterName
        sudo Set-NetIPInterface -InterfaceAlias $adapterName -Dhcp Enabled
        sudo Set-DnsClientServerAddress -InterfaceAlias $adapterName -ResetServerAddresses
    } else {
        if (-not $ipAddress -or -not $gateway -or -not $dnsServer) {
            echo '请输入参数进行配置, 例如: netconf -ipAddress "192.168.3.111" -gateway "192.168.3.2" -dnsServer "8.8.8.8"'
            return
        }
        # 设置 IP 地址
        sudo Set-NetIPAddress -InterfaceAlias $adapterName -IPAddress $ipAddress -PrefixLength 24

        # 设置默认网关
        sudo Set-NetRoute -InterfaceAlias $adapterName -DestinationPrefix 0.0.0.0/0 -NextHop $gateway

        # 设置 DNS 服务器
        sudo Set-DnsClientServerAddress -InterfaceAlias $adapterName -ServerAddresses $dnsServer
    }
}

function md5sum {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )

    $hash = Get-FileHash -Path $FilePath -Algorithm MD5 | Select-Object -ExpandProperty Hash
    return $hash
}

$env:HOME=$env:USERPROFILE
pyp "$env:HOME/maintain/main/pypkgs"

# 打开编辑环境变量面板
function board-env {
  rundll32 sysdm.cpl,EditEnvironmentVariables
}

# 打开蓝牙面板
function board-bluetooth {
  bthprops.cpl
}

# 打开网络适配器面板
function board-adapters {
  ncpa.cpl
}

function monitor-close {
  ControlMyMonitor.exe /SetValue Primary D6 5
}

function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath $cwd
    }
    Remove-Item -Path $tmp
}