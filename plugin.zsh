if [[ "$OSTYPE" == "freebsd"* ]]; then
    grep_bin='/usr/local/bin/grep'
    if [[ ! -f $grep_bin ]]; then
        echo "Try install GNU grep: pkg install gnugrep"
        return
    fi
    pattern='s/^([^:]+:[^:]+):\s*(.*)/\1:  \2/'
else
    grep_bin='grep'
    pattern='s/^([^:]+:[^:]+):\s*(.*)/\x1b[35m\1\x1b[0m:  \2/'
fi

function :fuzzy-search-and-edit:get-files() {
    local directory="$1"
    local fifo="$2"
    cd "$directory"
    command $grep_bin -r -nEHI '[[:alnum:]]' "." --exclude-dir=".git" \
        | cut -b3- \
        | command sed -ru $pattern > "$fifo"
}

function :fuzzy-search-and-edit:abort-job() {
    local match

    read -r match
    printf "%s\n" "$match"

    async_flush_jobs ":fuzzy-search-and-edit:worker"
}

function fuzzy-search-and-edit() {
    local dir="$(mktemp -d /tmp/fuzzy-search-and-edit.XXXXXX)"
    local fifo="$dir/fifo"

    mkfifo "$fifo"

    async_job ":fuzzy-search-and-edit:worker" ":fuzzy-search-and-edit:get-files" "$(pwd)" "$fifo"

    local match=$(
        fzf +x --ansi -1 < "$fifo" \
            | :fuzzy-search-and-edit:abort-job
    )

    if [ "$match" ]; then
        local file
        local line

        IFS=: read -r file line _ <<< "$match"

        # set defaults for the editor opening
        local editortouse='${EDITOR}'
        local linefmt="+%L"
        local filefmt="%F"
        local usetty=true

        # high level options
        if zstyle -t ':fuzzy-search-and-edit:editor' use-visual ; then
            usetty=false
            # only if VISUAL_EDITOR variable is set
            if [ -v VISUAL_EDITOR ] ; then
                editortouse='${VISUAL_EDITOR}'
            fi
            # else keep the default
        fi
        if zstyle -t ':fuzzy-search-and-edit:editor' alternate-line-syntax ; then
            linefmt=""
            filefmt="%F:%L"
        fi

        local tmpval=''
        # low-level options that will override all others
        if zstyle -s ':fuzzy-search-and-edit:editor:invocation-format' editor tmpval ; then
            editortouse="${tmpval}"
        fi
        if zstyle -s ':fuzzy-search-and-edit:editor:invocation-format' line tmpval ; then
            linefmt="${tmpval}"
        fi
        if zstyle -s ':fuzzy-search-and-edit:editor:invocation-format' file tmpval ; then
            filefmt="${tmpval}"
        fi
        if zstyle -t ':fuzzy-search-and-edit:editor:invocation-format' without-tty ; then
            usetty=false
        fi

        # parse the file and line format specifiers
        local linetouse=""
        local filetouse=""
        zformat -f linetouse "${linefmt}" L:${line} F:${file}
        zformat -f filetouse "${filefmt}" L:${line} F:${file}

        # construct the command-line.
        local cmdtorun=()

        # split the full expansion of editortouse and put each space separated argument into the array separately
        for A in ${(z)${(e)editortouse}} ; do
            cmdtorun+=(${A})
        done

        # append the options only if they aren't blank to avoid cases that don't parse properly like:
        # myeditor "" "myfile.txt:80"
        if [ -n "${linetouse}" ] ; then
            cmdtorun+=(${linetouse})
        fi
        if [ -n "${filetouse}" ] ; then
            cmdtorun+=(${filetouse})
        fi

        # run it, quoting each array element and providing tty if necessary
        if ${usetty} ; then
            "${cmdtorun[@]}" </dev/tty
        else
            "${cmdtorun[@]}"
        fi
    fi

    rm -r "$dir"

    zle -I
}

:fuzzy-search-and-edit:completed() {
    :
}

async_start_worker ":fuzzy-search-and-edit:worker"
async_register_callback ":fuzzy-search-and-edit:worker" \
    ":fuzzy-search-and-edit:completed"

zle -N fuzzy-search-and-edit
