# we *need* EPOCHREALTIME for the prompt to be accurate
zmodload zsh/datetime

# directly set the hooks instead of just adding to the hook, so ours runs first
function preexec {
  _CMD_TIMER=$EPOCHREALTIME
}


function precmd {
    if [[ $_CMD_TIMER ]]; then
        local elapsed_ms=$[ ($EPOCHREALTIME-$_CMD_TIMER) * 1000 ] elapsed
        if (( elapsed_ms > 60000 )) {
            # print everything over a minute as MM:SS
            printf -v elapsed "%02.0f:%02.0f" $[ ($elapsed_ms/1000.0) / 60 ] $[ ($elapsed_ms/1000.0) % 60 ]
        } elif (( elapsed_ms > 100 )) {
            printf -v elapsed "%.2fs" $[ $elapsed_ms/1000.0 ]
        } else  {
            printf -v elapsed "%.2fms" $elapsed_ms
        }
        RPROMPT="%F%(?.%F{green}.%F{red})%S%(?.󰄬.󰅖 %?)%s %F{#4c566a}%f%K{#4c566a}󱎫 ${elapsed}%k%F{#4c566a}%f"
        # dont change this every time we press enter
        unset _CMD_TIMER
    fi
    # set the title
    print -Pn "\e]0;zsh: %~\a"
}

# PROMPT="%B%F{magenta}%S %n %s %B%F{cyan}%S󰉋 %(4~|%-1~/…/%24<..<%2~%<<|%4~)%s%f%b "
PROMPT="%B%F{cyan}%S󰉋 %(4~|%-1~/…/%24<..<%2~%<<|%4~)%s%f%b "
# Prompt for nested things:
PS2="%B%S󰅪 %_%s%f%b "
# sudo prompt

export SUDO_PROMPT="$(print -P "\n%B%F{red}%S sudo%s%f%b ")"

# only the default, i have a couple more functions planed for this
TIMEFMT="User   %U
Kernel %S
Time   %E"
