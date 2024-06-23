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

local -a zo_extra=(
    "--prompt='󰉋 cd: '"
    "--pointer='>'"
    "--color=prompt:cyan:bold"
    "--no-scrollbar"
    "--no-separator"
    "--height=18"
    "--border=rounded"
    "--preview='lsd \"\$(echo {}|cut -f2)\"'"
    # "--preview-window=up,noborder"
)

export FZF_DEFAULT_OPTS="$colors"
export _ZO_FZF_OPTS="$colors ${(j: :)zo_extra}"

unset colors name zo_extra fzf_colors
