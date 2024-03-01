function preexec() {
  timer=$(($(date +%s%0N)/1000000))
}

function precmd() {
    if [ $timer ]; then
        local now=$(($(date +%s%0N)/1000000))
        local elapsed=$(($now-$timer))
        if [[ $elapsed -gt 60000 ]] 
        then
            local elapsed_f="$(($elapsed/60000.0))"
            local elapsed_u="$(printf "%.2f\n" "$elapsed_f")m"
        elif [[ $elapsed -gt 500 ]]
        then
            local elapsed_f="$(($elapsed/1000.0))"
            local elapsed_u="$(printf "%.2f\n" "$elapsed_f")s"
        else
            local elapsed_u="${elapsed}ms"
        fi
        RPROMPT="%F%(?.%F{green}.%F{red})%S%(?.󰄬.󰅖 %?)%s %F{#4c566a}%f%K{#4c566a}󱎫 ${elapsed_u}%k%F{#4c566a}%f"
        unset timer
    fi
    print -Pn "\e]0;zsh: %~\a"
}

# PROMPT="%B%F{magenta}%S %n %s %B%F{cyan}%S󰉋 %(4~|%-1~/…/%24<..<%2~%<<|%4~)%s%f%b "
PROMPT="%B%F{cyan}%S󰉋 %(4~|%-1~/…/%24<..<%2~%<<|%4~)%s%f%b "
# Prompt for nested things:
PS2="%B%S%_%s%f%b "
# sudo prompt
export SUDO_PROMPT="
[31;1m[30;41;1m sudo[0m[31;1m[0m " 
