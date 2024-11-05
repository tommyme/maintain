# Configuration variables
declare -g -A _sb_config=(
    mysql_table_size   10000
    mysql_table_num    10
    mysql_host         127.0.0.1
    mysql_port         3306
    mysql_time         120
    mysql_preheat_time 600
    mysql_db           sysbench

    redis_size         1000000
    redis_pipeline     20
)
# set val example: _sb_config[mysql_host]=localhost

# Test configurations
_sb_mysql_thread_counts=(1 4 8 16 32 64)
_sb_redis_clients_counts=(1 20 40 60 80 100)


# Sysbench profiles
declare -g -A _sb_profiles=(
    ro "oltp_read_only"
    wo "oltp_write_only"
    rw "oltp_read_write"
)

# Base command for MySQL tests
_sb_mysql_base_cmd() {
    local threads=$1
    echo "sysbench \
    --mysql-user=root \
    --mysql-host=\${_sb_config[mysql_host]} \
    --mysql-port=\${_sb_config[mysql_port]} \
    --mysql-db=\${_sb_config[mysql_db]} \
    --forced-shutdown=off \
    --time=\${_sb_config[mysql_time]} \
    --report-interval=1 \
    --events=0 \
    --table-size=\${_sb_config[mysql_table_size]} \
    --tables=\${_sb_config[mysql_table_num]} \
    --threads=$threads"
}

# MySQL preheat command
_sb_mysql_preheat_cmd() {
    _sb_mysql_base_cmd 256
}

sb-mysql-prepare() {
    local n=$(nproc)
    eval "$(_sb_mysql_base_cmd $n) oltp_insert prepare"
}

# Main MySQL benchmark function
sb-mysql() {
    local test_type=$1
    local rounds=${2:-1}
    local profile=${_sb_profiles[$test_type]}

    if [[ -z $profile ]]; then
        echo "Error: Invalid test type. Use 'ro', 'wo', or 'rw'."
        return 1
    fi

    local filename="$(create_tslog $test_type)"
    for threads in ${_sb_mysql_thread_counts[@]}; do
        for ((i=1; i<=rounds; i++)); do
            echo "Running test with $threads threads (round $i/$rounds)..."
            eval "$(_sb_mysql_base_cmd $threads) $profile run" | tee -a "$filename"
        done
    done
}

# MySQL preheat function
sb-mysql-preheat() {
    local test_type=$1
    local profile=${_sb_profiles[$test_type]}

    if [[ -z $profile ]]; then
        echo "Error: Invalid test type. Use 'ro', 'wo', or 'rw'."
        return 1
    fi

    echo "Preheating with test type: $test_type"
    eval "$(_sb_mysql_preheat_cmd) --time=\${_sb_config[mysql_preheat_time]} $profile run"
}

# Redis benchmark function
sb-redis() {
    local rounds=${1:-1}
    local output=""

    for clients in ${_sb_redis_clients_counts[@]}; do
        for ((i=1; i<=rounds; i++)); do
            echo "\"Clients\",\"$clients\""
            redis-benchmark -n \${_sb_config[redis_size]}  -c $clients -P \${_sb_config[redis_pipeline]}  -q -t set,get --csv
        done
    done
}

# Format Redis CSV output
sb-redis-fmtcsv() {
    if [[ ! -f $1 ]]; then
        echo "Error: File not found"
        return 1
    fi

    awk -F',' '
    BEGIN {
        order[1] = "\"Clients\""
        order[2] = "\"SET\""
        order[3] = "\"GET\""
    }
    {
        data[$1] = data[$1] "," $2
    }
    END {
        for (i=1; i<=3; i++) {
            key = order[i]
            print key substr(data[key], 1)
        }
    }
    ' "$1"
}

# Completion function for MySQL commands
_sb_mysql() {
    local -a options=(
        'ro:read-only test'
        'wo:write-only test'
        'rw:read-write test'
    )
    _describe 'options' options
}

# Register completions
compdef _sb_mysql sb-mysql
compdef _sb_mysql sb-mysql-preheat