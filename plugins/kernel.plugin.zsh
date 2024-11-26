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
        exver)
            shift 1;
            sed -i "/^EXTRAVERSION =/s/=.*/= $1/" Makefile
            echo "sed EXTRAVERSION done."
            ;;
        info)
            cat /proc/cmdline
            uname -a
            echo "zcat /proc/config.gz"
            ;;
        run)
            case "$2" in
                make3)
                    k run make2
                    echo make3
                    ;;
                make2)
                    echo make2
                    ;;
                bear)
                    echo bear
                    ;;
                *)
                    echo "etc"
                    ;;
            esac
            ;;
        trace)
            # local trace_home="/sys/kernel/debug/tracing"
            local trace_home="./tracing"
            case "$2" in
                clean)
                    sudo bash -c "echo nop > $trace_home/current_tracer"
                    # clean data
                    sudo bash -c "echo > $trace_home/trace"
                    sudo bash -c "echo 0 > $trace_home/events/enable"
                    ;;
                set)
                    shift 2
                    sudo bash -c "echo $1 > $trace_home/set_ftrace_filter"
                    sudo bash -c "echo $2 > $trace_home/current_tracer"
                    ;;
                run)
                    shift 2
                    sudo bash -c "echo 1 > $trace_home/tracing_on"
                    $@
                    sudo bash -c "echo 0 > $trace_home/tracing_on"
                    ;;
                info)
                    echo $trace_home/trace
                ;;

            esac
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
        'exver:sed extraversion in makefile'
        'info:check current linux kernel info'
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