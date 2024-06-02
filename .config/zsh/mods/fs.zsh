#!/bin/false
# vim: ft=zsh

# make filesystem naviation/file handling easier

if [[ "$1" == "load" ]] {

alias md="mkdir -p"

function mcd {
    if [[ -d "$1" ]] {
        cd "$1"
        return
    }
    mkdir -p "$1"
    cd "$1"
}

function mkf {
    local -a filenames=("$@")
    local i file no_ext
    for  ((i=1; i<=$#filenames; i++)) {
        file="${filenames[i]}"
        if [[ -f "$file" || -d "$file" ]] {
            print "File already exists: $file" > /dev/stderr
            continue
        }
        case "$file" in
            *\.c|*\.h)
                no_ext="${file%%.*}"
                local header source
                if [[ "${filenames[i+1]}" == "$no_ext\.c" ]] {
                    source="${filenames[i+1]}"
                    header="$file"
                } else {
                    source="$file"
                    header="${filenames[i+1]}"
                }
                ((i++))
                echo "#include \"$header\"" > "$source"
                echo "#pragma once" > "$header"
                ;;
            main.c)
                echo "int main(int argc, char* argv[]) {\n    return 0;\n}" > "$file"
                ;;
            main.py)
                echo "def main():\n    pass\n\nif __name__ == \"__main__\":\n    main()" > "$file"
                chmod +x "$file"
                ;;
            *\.sh)
                echo "#!/usr/bin/env bash" > "$file"
                chmod +x "$file"
                ;;
            *\.py)
                echo "#!/usr/bin/env python" > "$file"
                chmod +x "$file"
                ;;
            *)
                echo -n "" > "$file";;
        esac
    }
}

alias ft="file --mime-type -F$'\t'"
alias bft="file --brief --mime-type -N"


# ripgrep files
function rgf {
    local search_term="$1"
    local search_path
    if [[ -z "$2" ]] {
        search_path="$PWD"
        shift 1
    } else {
        search_path="$2"
        shift 2
    }
    local flags="$@"

    rg --color=never --files-with-matches $flags "$search_term" "$search_path"
}

function tmp {
    local tmpdir="$HOME/Tmp"
    local mode
    local files
    local force=0
    case "$1" in
        rm|del)
            mode=delete
            shift
            ;;
        rmf)
            mode=delete
            force=1
            shift
            ;;
        cp|copy)
            mode=copy
            shift
            files=("${@:2}")
            ;;
        *)
            mode=cd
            ;;
    esac
    local target="${1}"

    case $mode in 
        cd)
            if [[ -d "$tmpdir/$target" ]] {
                cd "$tmpdir/$target"
                return
            } else {
                mkdir -p "$tmpdir/$target"
                cd "$tmpdir/$target"
            }
            ;;
        delete)
            if rmdir "$tmpdir/$target" &> /dev/null; then
                return
            elif [[ $force == 1 ]]; then
                \rm -rf "$tmpdir/$target"
                return
            fi
            print -P -- "%F{red}$target is not empty\nUse %B\`$0 rmf $target\`%f%b"
            return 1
            ;;
        copy)
            if ! [[ -d "$tmpdir/$target" ]] {
                mkdir -p "$tmpdir/$target"
            }
            cp --target-directory="$tmpdir/$target" "${files[@]}"
            return
            ;;
    esac

}

# better realpath
function rp {
    print -l -- "${@:A}"
}
# basename
function bn {
    print -l -- "${@:t}"
}

function readfile {
    local arrayname="${1}"
    local filename="${2}"

    eval "IFS=$'\n' ${arrayname}=(\$(< "${filename}"))"
}

function readstream {
    local arrayname="${1}"
    local line  
    local -a buffer

    while read -r line; do
        buffer+=("$line")
    done

    eval "${arrayname}=("\${buffer}")"

}

# rm wrapper
function rmi {
    if (($# < 1)) {
        return 0
    }

    local -a files
    local -a dirs
    local -a links

    local file
    for file in "${@}"; do
        if [[ -L "$file" ]] {
            links+=("$file")
        } elif [[ -f "$file" ]] {
            files+=("$file")
        } elif [[ -d "$file" ]] {
            dirs+=("$file")
        } else {
            print -P "%F{red}Not a file, dir or symlink: $file%f" > /dev/stderr
            return 1
        }
    done

    local -a fmt=()
    if (($#files > 0)) {
        fmt+=("%F{magenta}󰈔 $#files file(s)%f")
    }
    if (($#dirs > 0)) {
        fmt+=("%F{cyan}󰉋 $#dirs dir(s)%f")
    }
    if (($#links > 0)) {
        fmt+=("%F{blue}󰌷 $#links link(s)%f")
    }
    print -Pn -- "%B${(j:\n:)fmt[@]}%b" "\n%B%F{red}%S󰩹 rm%s%f%b N[o]/y[es]/f[orce]/t[rash] "
    read -r -k 1 answer
    echo
    case "$answer" in 
        [tT])
            gio trash -- "${files[@]}" "${dirs[@]}" "${links[@]}"
            if (($? == 0)) {
                print -P "%F{green}󰩹 Successfully trashed $[$#files + $#dirs + $#links] element(s)%f"
            }
            ;;
        [yY])
            \rm -rI -- "${files[@]}" "${dirs[@]}" "${links[@]}"
            ;;
        [fF])
            \rm -rf -- "${files[@]}" "${dirs[@]}" "${links[@]}"
            echo
            ;;
        *|[Nn]) 
            echo
            return 1
            ;;
    esac
    echo
}

# like pwd but takes into account all the shell magic
alias pwf='print -P -- %~'



} elif [[ "$1" == "unload" ]] {

unfunction rgf mcd mkf tmp rp bn \
    rmi  \
    readfile readstream

unalias md ft bft pwf

}
