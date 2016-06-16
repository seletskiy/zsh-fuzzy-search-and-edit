function :fuzzy-search-and-edit:get-files() {
    local directory="$1"
    local fifo="$2"

    cd "$directory"

    exec 2>>/tmp/debug

    set -x

    command grep -r -nPHI '\w' -r "." --exclude-dir=".git" \
        | cut -b3- \
        | command sed -ru 's/^([^:]+:[^:]+):\s*(.*)/\x1b[35m\1\x1b[0m:  \2/' \
        > "$fifo"

    set +x
}

function :fuzzy-search-and-edit:abort-job() {
    while read match; do
        echo $match
        async_stop_worker fuzzy-search-and-edit:worker
    done
}

function fuzzy-search-and-edit() {
    local dir="$(mktemp --tmpdir -d fuzzy-search-and-edit.XXXXXX)"
    local fifo="$dir/fifo"

    mkfifo "$fifo"

    async_job ":fuzzy-search-and-edit:worker" \
        ":fuzzy-search-and-edit:get-files" "$(pwd)" "$fifo"

    local match=$(fzf --ansi -1 < "$fifo" | :fuzzy-search-and-edit:abort-job)

    if [ "$match" ]; then
        local file="$(cut -f1 -d: <<< "$match")"
        local line="$(cut -f2 -d: <<< "$match")"

        $EDITOR "$file" "+$line" < /dev/tty
    fi

    rm -r "$dir"

    zle -I
}

async_start_worker ":fuzzy-search-and-edit:worker"

zle -N fuzzy-search-and-edit

