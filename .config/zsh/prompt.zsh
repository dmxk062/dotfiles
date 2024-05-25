# we *need* EPOCHREALTIME for the prompt to be accurate
zmodload zsh/datetime

function __cmd_start_timestamp {
  _CMD_TIMER=$EPOCHREALTIME
}

add-zsh-hook preexec __cmd_start_timestamp

function __cmd_end_timestamp {
    if [[ $_CMD_TIMER ]]; then
        local elapsed_ms=$[ ($EPOCHREALTIME-$_CMD_TIMER) * 1000 ] elapsed
        if (( elapsed_ms > 60000 )) {
            printf -v elapsed "%.3fm" $[ $elapsed_ms/60000.0 ]
        } elif (( elapsed_ms > 100 )) {
            printf -v elapsed "%.2fs" $[ $elapsed_ms/1000.0 ]
        } elif (( elapsed_ms > 0.1 )) {
            printf -v elapsed "%.2fms" $elapsed_ms
        } else {
            printf -v elapsed "%.2fns" $[ $elapsed_ms ]
        }
        RPROMPT="%F%(?.%F{green}.%F{red})%S%(?.󰄬.󰅖 %?)%s %F{#4c566a}%f%K{#4c566a}󱎫 ${elapsed}%k%F{#4c566a}%f"
    fi
    # set the title
    print -Pn "\e]0;zsh: %~\a"
}
add-zsh-hook precmd __cmd_end_timestamp

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
