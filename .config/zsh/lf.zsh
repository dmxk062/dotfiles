# functions with prefix l- to interact with the lf instance the split was opened from

function lhidden-if-needed {
    if [[ "$1" == "."* ]]; then
        lf -remote "send $id set hidden"
    fi
}

function lselect {
    lhidden-if-needed "$1"

    lf -remote "send $id select ${(q)1:A}"
}

function lopen {
    lhidden-if-needed "$1"

    lf -remote "send $id select ${(q)1:A}"
    lf -remote "send $id open"
}
