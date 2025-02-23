function set-kernel-arch() {
    export kernel_arch=$1
    push_lvar kernel_arch $1
}

if [ -z "$xxx" ]; then
    set-kernel-arch arm64
fi

function _set_arch_completions() {
    local -a arch
    arch=("arm64" "arm")
    _describe 'architecture' arch
}
compdef _set_arch_completions set-kernel-arch


function set-kernel-img() {
    if [[ -d "$1" ]]; then  # is dir, try to find Image
        local _path=$(realpath "$1/arch/$kernel_arch/boot/Image")
    else    # is file
        local _path=$(realpath "$1")
    fi

    if [[ -f $_path ]]; then
        file $_path
        export kernel_img=$_path
        push_lvar kernel_img $_path
        echo "Kernel image set to $kernel_img"
    else
        echo "Kernel image not found for architecture $kernel_arch"
    fi
}

function set-kernel-rootfs() {
    local _path=$(realpath "$1")
    if [[ -f $_path ]]; then
        file $_path
        export kernel_rootfs=$_path
        push_lvar kernel_rootfs $_path
        echo "Kernel rootfs set to $kernel_rootfs"
    else
        echo "Kernel rootfs not found $kernel_rootfs"
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

function make-arch() {
    make ARCH=$kernel_arch CROSS_COMPILE=$(get-toolchain) -j $(nproc) $@
}

alias amend="git commit --amend"

function copy2img() {
    mkdir -p mount_rootfs
    sudo mount -t ext4 rootfs.img mount_rootfs -o loop
    sudo cp -r $1 mount_rootfs
    echo "copy done, enter bash ..."
    sudo bash
    sudo umount mount_rootfs
}

function k-rootfs-mnt-cpio.gz() {
    mkdir -p $dst
    gzip -dc $_path | cpio -idmv -D $dst
}

function k-rootfs-umt-cpio.gz() {
    cd $1
    find . | cpio -o -H newc > ${_path%.gz}
    gzip ${_path%.gz}
    rm -rf $1/*
    popd
}

function k-rootfs-mnt-ext4() {
    sudo mkdir -p $2
    sudo mount -t ext4 $1 $2
}

function k-rootfs-umt-ext4() {
    sudo umount $1
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
                    shift 2
                    set-kernel-rootfs $@
                    ;;
                arch)
                    shift 2
                    set-kernel-arch $@
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
            local trace_home="/sys/kernel/debug/tracing"
            case "$2" in
                clean)
                    sudo bash -c "echo nop > $trace_home/current_tracer"
                    # clean data
                    sudo bash -c "echo > $trace_home/trace"
                    # disable event in ftrace submodule
                    sudo bash -c "echo 0 > $trace_home/events/enable"
                    ;;
                set)
                    shift 2
                    sudo bash -c "echo $1 > $trace_home/current_tracer"     # function
                    sudo bash -c "echo $2 > $trace_home/set_ftrace_filter"  # function name
                    ;;
                cat)
                    sudo cat $trace_home/trace
                    ;;
                st)
                    sudo bash -c "echo 1 > $trace_home/tracing_on"
                    ;;
                ed)
                    sudo bash -c "echo 0 > $trace_home/tracing_on"
                    ;;
                run)
                    shift 2
                    k trace st
                    $@
                    k trace ed
                    ;;
                info)
                    echo $trace_home/trace
                ;;

            esac
            ;;
        rootfs)
            local _path=$kernel_rootfs
            local dst=$(dirname $_path)/mount_$(basename $_path)
            local filename=$(basename $_path)
            local type="${filename#*.}"
            case "$2" in
                mnt)
                    shift 2
                    echo "type: $type; path: $_path; dst: $dst"
                    sudo mkdir -p $dst
                    if command -v k-rootfs-mnt-$type &> /dev/null
                    then
                        k-rootfs-mnt-$type $_path $dst $@
                    else
                        echo "\e[31mk-rootfs-mnt-$type\e[0m not found!"
                    fi
                    ;;
                umt)
                    shift 2
                    if command -v k-rootfs-umt-$type &> /dev/null
                    then
                        k-rootfs-umt-$type $dst $@
                    else
                        echo "\e[31mk-rootfs-umt-$type\e[0m not found!"
                    fi
                    ;;
                push)
                    shift 2
                    if ! mount | grep -q "$dst"; then
                        echo "\e[32mauto mount...\e[0m"
                        k rootfs mnt
                    fi
                    echo "copy: $@ -> $dst"
                    sudo cp -r $@ $dst
                    ;;
                mpu)
                    # mount push umt
                    shift 2
                    k rootfs push $@
                    k rootfs umt
                    ;;
                cd)
                    shift 2
                    cd $dst
                    ;;
                *)
                    echo "command not found"
                    ;;
            esac
            ;;
        clangd)
            echo -e "CompileFlags:\n    Add: --target=aarch64-linux-gnu\n    Remove: -mabi=lp64" > .clangd
            echo "write to .clangd"
            echo "you can use ./scripts/clang-tools/gen_compile_commands.py to generate compile_commands.json"
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
        'trace:trace related commands'
        'rootfs:mnt/umt rootfs'
        'clangd:write .clangd file'
    )

    setsubcmds=(
        'img'
        'rootfs'
        'arch'
    )

    rootfssubcmds=(
        'mnt'
        'umt'
        'push'
        'mpu'
        'cd'
    )

    tracesubcmds=(
        'clean:clean trace'
        'set:set trace type and name'
        'cat:cat trace result'
        'run:traceOn; run sth; traceOff'
        'info:echo some info'
        'st:start trace'
        'ed:end trace'
    )

    if (( CURRENT == 2 )); then
        _describe 'sub-command' subcmds
    elif (( CURRENT == 3 )); then
        case "$words[2]" in
            set)
                _describe 'set-sub-command' setsubcmds
                ;;
            trace)
                _describe 'trace-sub-command' tracesubcmds
                ;;
            rootfs)
                _describe 'rootfs-sub-command' rootfssubcmds
                ;;
        esac
    elif (( CURRENT == 4 )); then
        case "$words[2]-$words[3]" in
            set-kernel-arch)
                local -a arch
                arch=("arm64" "arm")
                _describe 'architecture' arch
                ;;
            set-img)
                _files
                ;;
            set-rootfs)
                _files
                ;;
            rootfs-push)
                _files
                ;;
            trace-set)
                compadd $(sudo bash -c "cat /sys/kernel/debug/tracing/available_tracers")
                ;;
        esac
    fi
}

compdef _k_completions k

_make_arch_completions() {
    # 定义存储 .ko 文件的数组
    local -a completions

    # 检查当前目录是否是 Git 仓库
    if ls $PWD/.git &>/dev/null; then
        # 如果是 Git 仓库，获取 git status 的文件列表
        local -a git_files
        git_files=(${(f)"$(git status --porcelain=v1 -- drivers | awk '{print $2}')"})
        
        # 遍历 git_files，筛选文件夹和 .ko 文件
        for file in $git_files; do
            if [[ -d $file ]]; then
                # 如果是文件夹，查找其中的 .ko 文件
                local -a ko_files
                ko_files=(${(f)"$(find $file -type f -name '*.ko')"})
                completions+=($ko_files)
            elif [[ -f $file ]]; then
                # 如果是普通文件，跳过
                continue
            fi
        done
    fi

    # 定义固定的子命令
    local -a subcmds=(
        'menuconfig'
        'Image'
        'modules_install'
        'modules'
    )

    # 合并动态选项和固定选项
    _describe 'sub-command' subcmds
    if (( ${#completions[@]} > 0 )); then
        _values 'ko files' $completions
    fi
}



# dtb -- device-tree-compiler
function dtc2s() {
    local src=$1
    local dst="${2:-$1.dts}"  # usr arg2 first, or $1.dts
    echo $src "=>" $dst
    dtc -I dtb -O dts -o $dst $src
}
function dtc2b() {
    local src=$1
    local dst="${2:-$(basename $1 .dts)}"
    echo $src "=>" $dst
    dtc -I dts -O dtb -o $dst $src
}
function vimdtb() {
    dtc2s $1
    vim $1.dts
    dtc2b $1.dts
}

compdef _make_arch_completions make-arch