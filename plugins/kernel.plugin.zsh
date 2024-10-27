export kernel_img=""
export kernel_rootfs=""
export kernel_arch="arm64"

function set-arch() {
    export kernel_arch=$1
}

function _set_arch_completions() {
    local -a arch
    arch=("arm64" "arm")
    _describe 'architecture' arch
}
compdef _set_arch_completions set-arch


function set-kernel-img() {
    if [[ -f "$1/arch/$kernel_arch/boot/Image" ]]; then
        export kernel_img="arch/$kernel_arch/boot/Image"
        echo "Kernel image set to $kernel_img"
    else
        echo "Kernel image not found for architecture $kernel_arch"
    fi
}


function get-toolchain() {
    case $kernel_arch in
        arm64)
            echo "aarch64-linux-gnu-"
            ;;
        arm)
            echo "arm-linux-gnueabi-"
            ;;
        *)
            echo ""
            ;;
    esac
}

alias make-arch="make ARCH=\$kernel_arch CROSS_COMPILE=\$(get-toolchain) -j \$(nproc)"
alias amend="git commit --amend"

function copy2img() {
    mkdir -p mount_rootfs
    sudo mount -t ext4 rootfs.img mount_rootfs -o loop
    sudo cp -r $1 mount_rootfs
    echo "copy done, enter bash ..."
    sudo bash
    sudo umount mount_rootfs
}

# 定义命令函数
function k() {
    case "$1" in
        set)
            case "$2" in
                img)
                    shift 2
                    set-kernel-img $@
                    ;;
                rootfs)
                    echo "setting rootfs"
                    ;;
                arch)
                    shift 2
                    set-arch $@
                    ;;
                *)
                    echo "etc"
                    ;;
            esac
            ;;
        check)
            echo kernel_img     $kernel_img
            echo kernel_rootfs  $kernel_rootfs
            echo kernel_arch    $kernel_arch
            ;;
        *)
            echo "unknown subcommand"
            ;;
    esac
}

# 定义补全功能
_k_completions() {
    local -a subcmds
    local -a setsubcmds

    subcmds=(
        'set:set var for qemu and make'
        'check:check vars'
        'run:run sth'
    )

    setsubcmds=(
        'img'
        'rootfs'
        'arch'
    )

    if (( CURRENT == 2 )); then
        _describe 'sub-command' subcmds
    elif (( CURRENT == 3 )); then
        case "$words[2]" in
            set)
                _describe 'set-sub-command' setsubcmds
                ;;
        esac
    elif (( CURRENT == 4 )); then
        case "$words[3]" in
            arch)
                local -a arch
                arch=("arm64" "arm")
                _describe 'architecture' arch
                ;;
            img)
                compadd $(ls "$PWD")
                ;;
        esac
    fi
}

compdef _k_completions k