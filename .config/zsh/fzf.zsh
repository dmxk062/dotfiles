local -A fzf_colors=(
    ["fg"]="white"
    ["fg+"]="cyan"
    ["bg"]="black"
    ["bg+"]="black"
    ["preview-fg"]="white"
    ["preview-bg"]="black"
    ["hl"]="cyan"
    ["hl+"]="cyan"
    ["info"]="magenta"
    ["border"]="gray"
    ["prompt"]="white:regular"
    ["query"]="white:regular"
    ["pointer"]="cyan"
    ["spinner"]="cyan"
    ["marker"]="magenta"
    ["header"]="white"
)

local colors="--color="
local name
for name in "${(k)fzf_colors[@]}"; do
    colors="$colors$name:${fzf_colors[$name]},"
done
colors="${colors::-1}"

local fzf_opts=(
    "--pointer='>'"
    "--color=prompt:cyan:bold"
    "--no-scrollbar"
    "--no-separator"
    "--border=rounded"
)
local -a zo_extra=(
    "--prompt='󰉋 cd: '"
    "--height=18"
    "--preview='lsd \"\$(echo {}|cut -f2)\"'"
    # "--preview-window=up,noborder"
)

function nz {
    local res="$(fd --hidden -I --type=file -E "*.pyc" -E "*.o" -E "*.bin" -E "*.so" -E "*.tmp" -E "*cache*" -E "*.git/*" \
        |fzf --height=18 --prompt=" ed: " --preview='bat -p --color=always -- {}')"
    if [[ -z "$res" ]]; then
        return
    fi
    local parent="${res:h}"
    local abs="${res:A}"
    (cd "$parent"; nvim "$abs")
}

function _fzf_shell_hist {
    local res="$(fc -n -l 1000|awk '!seen[$2]++'|fzf --height=18 --prompt="hist: " -q "^$BUFFER")"
    BUFFER="${res}"
    zle end-of-line
    zle reset-prompt
}

function _fzf_insert_path {
    local res="$(fd --type=file --type=directory --no-hidden --no-ignore | fzf --height=18 --prompt="file: " --preview='bat -p --color=always -- {}')"
    BUFFER+="${res}"
    CURSOR+="${#res}"
    zle reset-prompt
}

zle -N fzf_shell_hist _fzf_shell_hist
zle -N fzf_insert_path _fzf_insert_path
bindkey '^[/' fzf_shell_hist
bindkey '^[f' fzf_insert_path

export FZF_DEFAULT_OPTS="$colors ${(j: :)fzf_opts}"
export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS ${(j: :)zo_extra}"

unset colors name zo_extra fzf_colors fzf_opts
