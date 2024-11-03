_sb_mysql_table_size="500000"
_sb_mysql_table_num="40"
_sb_mysql_host="localhost"
_sb_mysql_port="3306"
_sb_mysql_time="120"
_sb_mysql_preheat_time="600"
_sb_mysql_thread_counts=(1 4 8 16 32 64)

alias sb-mysql-base="sysbench \
--mysql-user=root \
--mysql-host=\$_sb_mysql_host \
--mysql-port=\$_sb_mysql_port \
--mysql-db=sysbench \
--forced-shutdown=off \
--time=\$_sb_mysql_time \
--report-interval=1 \
--events=0 \
--table-size=\$_sb_mysql_table_size \
--tables=\$_sb_mysql_table_num"
alias sb-mysql-preheat-base="sysbench \
--threads=256 \
--mysql-user=root \
--mysql-host=\$_sb_mysql_host \
--mysql-port=\$_sb_mysql_port \
--mysql-db=sysbench \
--forced-shutdown=off \
--time=\$_sb_mysql_preheat_time \
--report-interval=1 \
--events=0 \
--table-size=\$_sb_mysql_table_size \
--tables=\$_sb_mysql_table_num"

sb-mysql-preheat() {
    local profile_ro="/usr/share/sysbench/oltp_read_only.lua"
    local profile_wo="/usr/share/sysbench/oltp_write_only.lua"
    local profile_rw="/usr/share/sysbench/oltp_read_write.lua"

    profile="profile_$1"
    sb-mysql-preheat-base ${(P)profile} --threads=$threads run
}

sb-mysql() {
    local profile_ro="/usr/share/sysbench/oltp_read_only.lua"
    local profile_wo="/usr/share/sysbench/oltp_write_only.lua"
    local profile_rw="/usr/share/sysbench/oltp_read_write.lua"

    profile="profile_$1"
    rounds="${2:-1}"    # default 1
    filename="$(create_tslog $1)"
    for threads in "${_sb_mysql_thread_counts[@]}"; do
        for ((i=1; i<=rounds; i++)); do
            sb-mysql-base ${(P)profile} --threads=$threads run | tee -a "$filename"
        done
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

_sb_redis_clients_counts=(1 20 40 60 80 100)
function sb-redis() {
    rounds="${1:-1}"    # default 1
    for clients in "${_sb_redis_clients_counts[@]}"; do
        for ((i=1; i<=rounds; i++)); do
            echo "\"Clients\",\"$clients\""
            redis-benchmark -n 1000000 -c $clients -P 20 -q -t set,get --csv
        done
    done
}

function sb-redis-fmtcsv() {
    awk -F',' '
    {
        data[$1] = data[$1] "," $2
    }
    END {
        order[1] = "\"Clients\""
        order[2] = "\"SET\""
        order[3] = "\"GET\""
        for (i=1; i<=3; i++) {
            key = order[i]
            print key substr(data[key], 1)
        }
    }
    ' $1
}

compdef _sb_mysql sb-mysql
compdef _sb_mysql sb-mysql-preheat