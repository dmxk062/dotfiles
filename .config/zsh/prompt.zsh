# we *need* EPOCHREALTIME for the prompt to be accurate
zmodload zsh/datetime

declare -A _promptvars
# directly set the hooks instead of just adding to the hook, so ours runs first
function preexec {
    _promptvars[timer]=$EPOCHREALTIME
}


PROMPT="%B%F{cyan}%S󰉋 %(4~|%-1~/…/%24<..<%2~%<<|%4~)%s%f%b "
function precmd {
    # dont print a new time on every single <cr>, just if a command ran
    if (( _promptvars[timer] > 0)); then
        local elapsed_ms=$[ ( $EPOCHREALTIME-$_promptvars[timer] )* 1000 ] elapsed
        if (( elapsed_ms > 60000 )) {
            # print everything over a minute as MM:SS
            printf -v elapsed "%02.0f:%02.0f" $[ ($elapsed_ms/1000.0) / 60 ] $[ ($elapsed_ms/1000.0) % 60 ]
        } elif (( elapsed_ms >= 100 )) {
            printf -v elapsed "%.2fs" $[ $elapsed_ms/1000.0 ]
        } else  {
            printf -v elapsed "%.2fms" $elapsed_ms
        }
        RPROMPT="%F%(?.%F{green}.%F{red})%S%(?.󰄬.󰅖 %?)%s %F{$ZSH_COLORS_RGB[light-gray]}%f%K{$ZSH_COLORS_RGB[light-gray]}󱎫 ${elapsed}%k%F{#4c566a$ZSH_COLORS_RGB[light-gray]}%f"
    fi
    # set the title
    print -Pn "\e]0;zsh: %~\a"
    if [[ -n "$VIRTUAL_ENV" ]] {
        RPROMPT="%B%F{$ZSH_COLORS_RGB[orange]}%S venv%s%b%f ${RPROMPT}"
    }
    _promptvars[timer]=0
}

# Prompt for nested things:
PS2="%B%S󰅪 %_%s%f%b "
# sudo prompt

export SUDO_PROMPT="$(print -P "\n%B%F{red}%S sudo%s%f%b ")"

# only the default, i have a couple more functions planed for this
TIMEFMT="User   %U
Kernel %S
Time   %E"

# disable python venv
export VIRTUAL_ENV_DISABLE_PROMPT=1
