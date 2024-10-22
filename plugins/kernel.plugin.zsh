export kernel_img=""
export kernel_rootfs=""
export kernel_arch=""

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
    if [[ -f "arch/$kernel_arch/boot/Image" ]]; then
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

function kernel-check() {
    echo kernel_img     $kernel_img
    echo kernel_rootfs  $kernel_rootfs
    echo kernel_arch    $kernel_arch
}

alias make-arch="make ARCH=\$kernel_arch CROSS_COMPILE=\$(get-toolchain) -j \$(nproc)"