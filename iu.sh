#!/bin/bash

# 定义变量 a='test' 中间没有空格
# install_info="$HOME/.ubt_install_info"
# jumpIfDoneElseDo()  { if [ ! $(cat "$install_info" | grep "$1") ] ; then $2 ; fi } # abadoned
# markDone()          { echo "$1" >> "$install_info"; }
tips()              { clear;echo $1; }
menu()              { id=0;for i in $@;do echo $id. $i;((id++));done;read -p "input your options(eg: '012'):" options; }
exec_choice()       { id=0;for i in $@;do if [[ $options =~ "$id" ]];then $i;fi;((id++));done }
mk_dir()            { if [ ! -d "$1" ];then mkdir "$1";fi }

menu "base"\
     "ctf"\
     "docker"\
     "ubt_Desktop_essential"\
     "zsh(twice)"\
     "wsl_desktop"\
     "termux"\
     "vps_setup"

base(){
    menu "core" "git_init" "github_ssh_login_key" "nvim(plugins)" "etc_sudoers"
    core(){
        echo "installing base modules..."
        sudo apt-get update && sudo apt-get install -y wget vim curl neofetch zsh htop python3-pip gcc neovim git proxychains sudo
        sudo apt-get install -y iproute2 net-tools
        # sudo vim /etc/ssh/sshd_config
        sudo ln -s /usr/bin/python3 /usr/bin/python # mac中无效
        sudo ln -s /usr/bin/python3 /usr/local/bin/python3 # mac中无效
        read -p "if you want to install&config ssh?(y/n)" xxx
        if [ $xxx == "y" ]; then
            sudo apt-get install openssh-server
            read -p "enable Password Authentication?(ENTER to continue, any content to jump.)" xxx
            if [ ! $xxx ];then
                sudo sed -i "/PasswordAuthentication/c PasswordAuthentication yes" /etc/ssh/sshd_config
            fi
            sudo service ssh restart
            echo "you can run:  systemctl enable ssh"
        fi
        read -p "if you want to modify hostname?(y/n)" xxx
        if [ $xxx == "y" ]; then
            read -p "input new hostname:" hostname
            sudo hostnamectl set-hostname $hostname
        fi
    }
    git_init(){
        ssh-keygen -t rsa -C "mail"
        cat ~/.ssh/id_rsa.pub
        read -p "please copy the key & goto https://github.com/settings/ssh/new"
        git config --global user.email "mail"
        git config --global user.name "username"
    }
    github_ssh_login_key(){ bash <(curl -fsSL love4cry.cn/key.sh) -g tommyme; }
    NVIM(){ curl -sLf https://spacevim.org/install.sh | bash; }
    etc_sudoers(){
        read -p "1. will modify [sudo]->NOPASSWD; 2. preserve proxy env to root" xxx
        sudo sed -i "/^%sudo/s/ALL$/NOPASSWD:\ ALL/g" /etc/sudoers
        sudo sed -i "/env_reset/a\Defaults  env_keep += \"http_proxy https_proxy all_proxy\"" /etc/sudoers
    }
    funcs=(core git_init github_ssh_login_key NVIM)
    exec_choice ${funcs[*]}
}
ctf(){
    menu "base" "pwn" "re" "firmware" "x86_suppport" "Penetration"
    base(){
        # pwntools gdb
        sudo apt-get install -y python3 python3-pip python3-dev git libssl-dev libffi-dev build-essential gdb gdb-multiarch
    }
    pwn(){
        # repos_pwn
        repos_dir="$HOME/repos_pwn" 
        mkdir "$repos_dir"
        pip3 install pwntools

        # ropgadget
        sudo pip install capstone
        cd "$repos_dir" && git clone https://github.com/JonathanSalwan/ROPgadget
        cd ROPgadget && python setup.py install
            # cp -r scripts /home/ybw/.local/lib/python3.9/site-packages/ROPGadget-6.6.dist-info

        # pwndbg    
        cd "$repos_dir" && git clone https://github.com/pwndbg/pwndbg
        cd pwndbg && ./setup.sh

        # pwngdb
        cd "$repos_dir" && git clone https://github.com/scwuaptx/Pwngdb.git 

        # modify ~/.gdbinit
        echo -e "source $repos_dir/pwndbg/gdbinit.py\nsource $repos_dir/Pwngdb/pwngdb.py\nsource $repos_dir/Pwngdb/angelheap/gdbinit.py\ndefine hook-run\npython\nimport angelheap\nangelheap.init_angelheap()\nend\nend" > "$HOME/.gdbinit"

        # one_gadget
        sudo apt-get install -y ruby
        sudo gem install one_gadget

        # pwn project (includes buuctf libc)
        cd ~ && git clone https://github.com/tommyme/pwn


        # glibc_all_in_one
        cd "$repos_dir" && git clone https://github.com/matrix1001/glibc-all-in-one
        cd glibc-all-in-one || exit
        ./download 2.23-0ubuntu11.3_amd64   # 本地调试 ubt16 x64
        ./download 2.23-0ubuntu11.3_i386    # 本地调试 ubt16 x86


        # LibcSearcher
        # cd "$repos_dir" && git clone https://github.com/lieanu/LibcSearcher.git
        # cd LibcSearcher && sudo python3 setup.py develop
        # cd libc-database || exit 
        # ./add ~/repos_pwn/glibc-all-in-one/libs/2.23-0ubuntu11.3_i386/libc.so.6     # 本地调试 ubt16 x86
        # ./add ~/repos_pwn/glibc-all-in-one/libs/2.23-0ubuntu11.3_amd64/libc.so.6    # 本地调试 ubt16 x64
        # ./add ~/pwn/buuoj/16/64/libc.so.6   # 线上调试 ubt16 x64
        # ./add ~/pwn/buuoj/16/32/libc.so.6   # 线上调试 ubt16 x86
        
        # patchElf
        sudo apt-get install -y autoconf automake libtool 
        cd "$repos_dir" && git clone https://github.com/NixOS/patchelf
        cd patchelf || exit
        ./bootstrap.sh && ./configure && make && sudo make install && make check

        # seccomp-tools
        sudo apt install gcc ruby-dev && gem install seccomp-tools
    }
    re(){
        repos_dir="$HOME/repos_re" 
        mkdir "$repos_dir"
        # deflat
        cd "$repos_dir" && git clone https://github.com/cq674350529/deflat 
    }
    firmware(){
        repos_dir="$HOME/repos_firmware" 
        mkdir "$repos_dir"
        # binwalk
        sudo apt-get install -y binwalk 
    }
    x86(){
        # x86 support
        sudo dpkg --add-architecture i386
        sudo apt-get update
        sudo apt-get dist-upgrade
        sudo apt-get install -y libc6:i386 libc6-dev-i386
    }
    pene(){
        repos_dir="$HOME/repos_firmware" 
        mkdir "$repos_dir"
        # sqlmap
        cd "$repos_dir" && git clone https://github.com/sqlmapproject/sqlmap
        # oneForAll
        cd "$repos_dir" && git clone https://github.com/shmilylty/OneForAll
        # JsFinder
        cd "$repos_dir" && git clone https://github.com/Threezh1/JSFinder
        # dirsearch
        cd "$repos_dir" && git clone https://github.com/maurosoria/dirsearch
    }
    funcs=(base pwn re firmware x86 pene)
    exec_choice ${funcs[*]}
}
docker(){
    # docker canbe installed by `apt install docker.io`
    menu "base" "change_source" "portainer" "netdata" "nps" "cloudreve"
    base(){ read -p "this is for ubuntu user: " xxx; curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun; }
    portainer(){
        sudo docker run -d -p 9000:9000 -p 8000:8000 \
            -v /var/run/docker.sock:/var/run/docker.sock \
            --restart unless-stopped \
            --name portainer portainer/portainer-ce
    }
    netdata(){
        sudo docker run -d --name=netdata \
            -p 19999:19999 \
            -v netdataconfig:/etc/netdata \
            -v netdatalib:/var/lib/netdata \
            -v netdatacache:/var/cache/netdata \
            -v /etc/passwd:/host/etc/passwd:ro \
            -v /etc/group:/host/etc/group:ro \
            -v /proc:/host/proc:ro \
            -v /sys:/host/sys:ro \
            -v /etc/os-release:/host/etc/os-release:ro \
            --restart unless-stopped \
            --cap-add SYS_PTRACE \
            --security-opt apparmor=unconfined \
            netdata/netdata
    }
    nps(){
        read -p "prepare ~/nps/conf first! or you can't continue" xxx
        sudo docker run -d --name nps --net=host \
            -v ~/nps/conf/:/conf \
            ffdfgdfg/nps
    }
    cloudreve(){
        local home="$HOME/apps_docker/cloudreve"
        mkdir -p $home
        cd $home
        mkdir uploads config db avatar

        docker run -d \
            --name cloudreve \
            -e PUID=1000 \
            -e PGID=1000 \
            -e TZ="Asia/Shanghai" \
            -p 5212:5212 \
            --restart=unless-stopped \
            -v $home/uploads:/cloudreve/uploads \
            -v $home/config:/cloudreve/config \
            -v $home/db:/cloudreve/db \
            -v $home/avatar:/cloudreve/avatar \
            xavierniu/cloudreve
    }
    funcs=(base change_source portainer netdata nps cloudreve)
    exec_choice ${funcs[*]}

}
Desktop(){
    echo "installing vscode..."
    echo "sudo dpkg -i <code.deb>"
    
    echo "installing FiraCode"
    sudo apt install fonts-firacode
}
zsh(){
    menu "ohmyzsh" "plugins" "fix_paste_problems"
    ohmyzsh(){
        echo "installing ohmyzsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    }
    plugins(){
        repos_dir="$HOME/.oh-my-zsh/custom/plugins"
        # plugins: zsh-autosuggestions; zsh-syntax-highlighting;
        git clone "https://github.com/zsh-users/zsh-autosuggestions" "$repos_dir/zsh-autosuggestions" 
        git clone "https://github.com/zsh-users/zsh-syntax-highlighting" "$repos_dir/zsh-syntax-highlighting"

        rm ~/.zshrc && ln -s $HOME/maintain/.zshrc $HOME
        echo "=====please source your .zshrc!!!======"
    }
    fix(){ vim ~/.oh-my-zsh/lib/misc.zsh; }
    funcs=(ohmyzsh plugins fix)
    exec_choice ${funcs[*]}
}
wsl_desktop(){
    # ref: https://harshityadav95.medium.com/install-gui-desktop-in-wsl2-ubuntu-20-04-lts-in-windows-10-ae0d8d9e4459
    sudo apt-get install -y xfce4 xfce4-goodies
    sudo apt-get install xrdp
    sudo chmod a+w /etc/xrdp/startwm.sh
    sudo sed -i "33,34d" /etc/xrdp/startwm.sh
    sudo echo -e "# xce4\nstartxfce4" >> /etc/xrdp/startwm.sh

    sudo cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak
    sudo sed -i 's/3389/3390/g' /etc/xrdp/xrdp.ini # you can specify port here(3390 in this case)
    sudo sed -i 's/max_bpp=32/#max_bpp=32\nmax_bpp=128/g' /etc/xrdp/xrdp.ini
    sudo sed -i 's/xserverbpp=24/#xserverbpp=24\nxserverbpp=128/g' /etc/xrdp/xrdp.ini
    sudo echo xfce4-session > ~/.xsession # enable dbus
    sudo systemctl enable dbus
    sudo /etc/init.d/dbus start
    sudo /etc/init.d/xrdp start
}
mac_essencial(){
    echo "make sure you have brew installed on your mac!"
    # /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install curl wget neofetch git htop iproute2mac
    brew install --cask docker
    # brew install miniconda
    brew install android-platform-tools
}
termux(){
    passwd
    termux-change-repo
    ln -s ~/maintain/tools/* /data/data/com.termux/files/usr/bin
    pkg install wget vim curl zsh git neofetch python htop tsu openssh
    pkg install libxml2 libxslt
    termux-setup-storage # 访问手机存储区
    pip3 install -r requirements.txt
    ln -s /storage/emulated/0/Android/data/com.tencent.mobileqq/Tencent/QQfile_recv ~/storage/qq_file_recv
    echo "more info, please goto wiki: https://wiki.termux.com/wiki/Main_Page"
}
vps_setup(){
    if [ ! -e router ]; then echo "dir `router` not exists, exit!"; exit 1; fi
    ## nginx
    apt install speedtest-cli nginx
    service nginx start

    ## acme
    read -p "please input your domain name: " domain
    sed -i 's/www.example.com/$domain/g' acme/issuer.sh 
    sed -i 's/www.example.com/$domain/g' start.sh 
    sed -i 's/www.example.com/$domain/g' xray/config.json 

    bash acme/daemon.sh 
    bash acme/register.sh
    bash acme/issuer.sh 

    ## xray
    bash start.sh 
    docker logs -f --tail 20 xray

    ## bbr
    if [ $(lsmod | grep bbr) ]; then
        echo "bbr already loaded."
    else
        echo -e "进入root 输入以下指令:\n"\
             "sudo modprobe tcp_bbr    # 加载模块\n"\
             'echo "tcp_bbr" >> /etc/modules-load.d/modules.conf\n'\
             'echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf\n'\
             'echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf\n'\
             'sysctl -p'
            # sysctl -p 保存生效
            # 检测bbr状态
            # sysctl net.ipv4.tcp_available_congestion_control
            # sysctl net.ipv4.tcp_congestion_control
    fi
}
funcs=(base ctf docker Desktop zsh wsl_desktop termux vps_setup)
exec_choice ${funcs[*]}
