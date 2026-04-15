#!/bin/bash
#
# Ubuntu initial setup script
#
# Usage: run the script, select an option.
#

set -e

tips() { clear; echo "$1"; }
menu() {
    id=0
    for i in "$@"; do
        echo "$id. $i"
        ((id++))
    done
    read -p "input your options (e.g. '012'): " options
}
exec_choice() {
    id=0
    for i in "$@"; do
        if [[ "$options" == *"$id"* ]]; then "$i"; fi
        ((id++))
    done
}

# ============================================================
# Section: base

base() {
    menu "core" "git_init" "github_ssh_login_key" "nvim" "etc_sudoers"

    core() {
        echo "installing base modules..."
        sudo apt-get update
        sudo apt-get install -y wget vim curl neofetch zsh htop python3-pip gcc git
        sudo apt-get install -y iproute2 net-tools fzf zoxide
        sudo ln -s /usr/bin/python3 /usr/bin/python
        sudo ln -s /usr/bin/python3 /usr/local/bin/python3

        read -p "install & config ssh? (y/n) " xxx
        if [[ "$xxx" == "y" ]]; then
            sudo apt-get install -y openssh-server
            read -p "enable PasswordAuthentication? (Enter to continue, any content to skip) " xxx
            if [[ ! "$xxx" ]]; then
                sudo sed -i "/PasswordAuthentication/c PasswordAuthentication yes" /etc/ssh/sshd_config
            fi
            sudo service ssh restart
            echo "you can run: systemctl enable ssh"
        fi

        read -p "modify hostname? (y/n) " xxx
        if [[ "$xxx" == "y" ]]; then
            read -p "input new hostname: " hostname
            sudo hostnamectl set-hostname "$hostname"
        fi
    }

    git_init() {
        ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
        cat ~/.ssh/id_rsa.pub
        read -p "copy the key and go to https://github.com/settings/ssh/new"
        git config --global user.email "your_email@example.com"
        git config --global user.name "tommyme"
    }

    github_ssh_login_key() {
        bash <(curl -fsSL https://love4cry.cn/key.sh) -g tommyme
    }

    nvim() {
        # Neovim AppImage (no install needed, just download and chmod +x)
        local nvimgh="https://github.com/neovim/neovim/releases/download/v0.10.0/nvim-linux64.tar.gz"
        local dest="$HOME/.local/nvim"
        mkdir -p "$dest"
        curl -fsSL "$nvimgh" | tar xz -C "$dest" --strip-components=1
        chmod +x "$dest/bin/nvim"
        export PATH="$dest/bin:$PATH"
        echo "nvim installed at $dest/bin/nvim"
        echo "add $dest/bin to your PATH"
    }

    etc_sudoers() {
        echo "1. modify sudo -> NOPASSWD; 2. preserve proxy env to root"
        sudo sed -i "/^%sudo/s/ALL$/NOPASSWD: ALL/g" /etc/sudoers
        sudo sed -i "/env_reset/a Defaults env_keep += \"http_proxy https_proxy all_proxy\"" /etc/sudoers
    }

    funcs=(core git_init github_ssh_login_key nvim etc_sudoers)
    exec_choice "${funcs[@]}"
}

# ============================================================
# Section: zsh (CORE)

zsh_setup() {
    local repos_dir="$HOME/.oh-my-zsh/custom/plugins"
    local maintain_zshrc="$HOME/maintain/.zshrc"

    echo "installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    echo "installing plugins..."
    git clone "https://github.com/zsh-users/zsh-autosuggestions" "$repos_dir/zsh-autosuggestions"
    git clone "https://github.com/zsh-users/zsh-syntax-highlighting" "$repos_dir/zsh-syntax-highlighting"

    echo "linking .zshrc..."
    rm -f "$HOME/.zshrc"
    ln -s "$maintain_zshrc" "$HOME/.zshrc"

    # Also link custom plugins from maintain if they exist
    if [ -d "$HOME/maintain/plugins" ]; then
        for plugin in "$HOME/maintain/plugins"/*.plugin.zsh; do
            [ -e "$plugin" ] || continue
            local name=$(basename "$plugin" .plugin.zsh)
            ln -sf "$plugin" "$repos_dir/$name.plugin.zsh" 2>/dev/null || true
        done
        echo "linked custom plugins from ~/maintain/plugins/"
    fi

    echo ""
    echo "===== zsh setup complete! ====="
    echo "Run: exec zsh"
    echo "Then restart your terminal."
}

# ============================================================
# Section: docker

docker_setup() {
    menu "install" "portainer" "netdata"

    install_docker() {
        curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
        sudo usermod -aG docker "$USER"
        echo "logout and login to apply docker group"
    }

    portainer() {
        sudo docker run -d -p 9000:9000 -p 8000:8000 \
            -v /var/run/docker.sock:/var/run/docker.sock \
            --restart unless-stopped \
            --name portainer portainer/portainer-ce
    }

    netdata() {
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

    funcs=(install_docker portainer netdata)
    exec_choice "${funcs[@]}"
}

# ============================================================
# Section: wsl_desktop

wsl_desktop() {
    sudo apt-get install -y xfce4 xfce4-goodies
    sudo apt-get install -y xrdp
    sudo chmod a+w /etc/xrdp/startwm.sh
    sudo sed -i "33,34d" /etc/xrdp/startwm.sh
    sudo echo -e "# xfce4\nstartxfce4" >> /etc/xrdp/startwm.sh

    sudo cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak
    sudo sed -i 's/3389/3390/g' /etc/xrdp/xrdp.ini
    sudo sed -i 's/max_bpp=32/#max_bpp=32\nmax_bpp=128/g' /etc/xrdp/xrdp.ini
    sudo sed -i 's/xserverbpp=24/#xserverbpp=24\nxserverbpp=128/g' /etc/xrdp/xrdp.ini
    sudo echo xfce4-session > ~/.xsession
    sudo systemctl enable dbus
    sudo /etc/init.d/dbus start
    sudo /etc/init.d/xrdp start
}

# ============================================================
# Section: mac

mac_setup() {
    menu "brew" "basic" "fonts" "casks" "config"

    install_brew() {
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    }

    basic() {
        brew install gsed fzf zoxide yazi
    }

    fonts() {
        echo "installing Nerd Fonts (skip font-space-mono-nerd-font due to Homebrew bug)..."
        brew install font-hack-nerd-font # use "hack nerd font" in softwares 
        brew install font-fira-code-nerd-font
        brew install font-jetbrains-mono-nerd-font
        brew install font-ubuntu-mono-nerd-font
    }

    casks() {
        echo "installing casks..."
        brew install --cask betterdisplay
        brew install --cask stats
        brew install --cask hiddenbar
        brew install --cask karabiner-elements
        brew install --cask orbstack
        brew install --cask qlmarkdown
        brew install --cask qlvideo
        brew install --cask quicklook-json
        brew install --cask raycast
        brew tap farion1231/ccswitch
        brew install --cask cc-switch
        brew install --cask cmux
    }

    config() {
        echo "creating symlinks..."
        mkdir -p "$HOME/.local/bin"
        ln -sf /Applications/cmux.app/Contents/Resources/bin/cmux "$HOME/.local/bin/cmux"

        echo "linking Karabiner config..."
        mkdir -p "$HOME/.config/karabiner"
        ln -sf "$HOME/maintain/main/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
    }

    funcs=(install_brew fonts casks config)
    exec_choice "${funcs[@]}"
}

# ============================================================
# Section: termux

termux_setup() {
    passwd
    termux-change-repo
    ln -s ~/maintain/tools/* /data/data/com.termux/files/usr/bin 2>/dev/null || true
    pkg install wget vim curl zsh git neofetch python htop tsu openssh
    pkg install libxml2 libxslt
    termux-setup-storage
    echo "more info: https://wiki.termux.com/wiki/Main_Page"
}

# ============================================================
# Main menu

tips "System Setup"

echo "=============================================="
echo "  0. base        - install base tools"
echo "  1. zsh         - install zsh + oh-my-zsh (CORE)"
echo "  2. docker      - docker setup"
echo "  3. wsl_desktop - WSL2 GUI desktop"
echo "  4. termux      - termux setup"
echo "  5. mac         - macOS brew & casks"
echo "=============================================="
echo ""
echo "zsh is the most important step. After"
echo "installation, run 'exec zsh' to switch."
echo ""

read -p "select options (e.g. '01'): " options

funcs=(base zsh_setup docker_setup wsl_desktop termux_setup mac_setup)
exec_choice "${funcs[@]}"
