_sb_mysql_table_size="500000"
_sb_mysql_table_num="40"
_sb_mysql_host="localhost"
_sb_mysql_port="3306"

alias sb-mysql-base='sysbench --mysql-user=root --mysql-host=$_sb_mysql_host --mysql-port=$_sb_mysql_port --mysql-db=sysbench --forced-shutdown=off --time=120 --report-interval=1 --events=0 --table-size=$_sb_mysql_table_size --tables=$_sb_mysql_table_num'

sb-mysql-ro() {
    sb-mysql-base /usr/share/sysbench/oltp_read_only.lua $@
}

sb-mysql() {
    local profile_ro="/usr/share/sysbench/oltp_read_only.lua"
    local profile_wo="/usr/share/sysbench/oltp_write_only.lua"
    local profile_rw="/usr/share/sysbench/oltp_read_write.lua"

    read -t 5 "preheat?If you want to do preheat?(N/y)"
    preheat=${preheat:-N}
    if [[ "$preheat" == [Nn] ]]; then
        echo "do preheat..."
        sysbench /usr/share/sysbench/oltp_read_only.lua --threads=256 --mysql-user=root --mysql-host=$_sb_mysql_host --mysql-port=$_sb_mysql_port --mysql-db=sysbench --forced-shutdown=off --time=600 --report-interval=1 --events=0 --table-size=$_sb_mysql_table_size --tables=$_sb_mysql_table_num run
    fi

    profile="profile_$1"

    filename="$(create_tslog $1)"
    for threads in 1 4 8 16 32 64 128 256; do
        sb-mysql-base ${(P)profile} --threads=$threads run | tee -a "$filename"
    done
}

function _sb_mysql() {
    local options=(
        "ro: read-only test"
        "wo: write-only test"
        "rw: read-write test"
    )
    _describe 'options' options
}

compdef _sb_mysql sb-mysql