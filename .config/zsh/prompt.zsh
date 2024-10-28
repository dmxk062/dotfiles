# we *need* EPOCHREALTIME for the prompt to be accurate
zmodload zsh/datetime

_PROMPTTIMER=0
# directly set the hooks instead of just adding to the hook, so ours runs first
function preexec {
    _PROMPTTIMER=$EPOCHREALTIME
}

psvar=(
    0ms           # 1 time of previous command
    "cyan"        # 2 color of prompt
    ""            # 3 git branch
    ""            # 4 git modified
    ""            # 5 git modified, staged?
    ""            # 6 git deleted
    ""            # 7 git deleted, staged?
    ""            # 8 git added
    ""            # 9 git added, staged?
    ""            # 10 git renamed
    ""            # 11 git ahead
    ""            # 12 git behind
    ""            # 13 python venv?
    ""            # 14 current dir readable
)

# change the color of the prompt based on mode
# PROMPT="%B%F{cyan}%S󰉋 %(4~|%-1~/…/%24<..<%2~%<<|%4~)%s%f%b "
function zvm_after_select_vi_mode {
    local -A mode_colors=(
        ["$ZVM_MODE_NORMAL"]="cyan"
        ["$ZVM_MODE_INSERT"]="cyan"
        ["$ZVM_MODE_VISUAL"]="12"
        ["$ZVM_MODE_VISUAL_LINE"]="12"
        ["$ZVM_MODE_REPLACE"]="red"
    )
    psvar[2]="$mode_colors[$ZVM_MODE]"
}

function _update_git_status {
    # only update if inside a git dir that isnt ignored
    git check-ignore . &> /dev/null
    # returns 0 if dir ignored and 1 if not but still git
    if (($? == 1)); then
        local type gstatus submod file
        local modified="" deleted="" added="" renamed="" smodified="" sdeleted="" sadded="" _branch branch="" remote="" ahead="" behind=""
        while read -r type gstatus submod _ _ _ file; do
            case "$type" in 
                (\#) 
                    case "$gstatus" in 
                        (branch.oid);;
                        (branch.head) branch="$submod";;
                        (branch.upstream) upstream="$submod";;
                        (branch.ab) 
                            ahead="$submod"
                            behind="$hname"
                            ahead="${ahead#+}"
                            behind="${behind#-}"
                            if [[ "$ahead" == -* ]] {
                                behind="${ahead#-}"
                            }

                            [[ "$ahead" == 0 ]]&&ahead=""
                            [[ "$behind" == 0 ]]&&behind=""
                            ;;
                    esac
                    ;;
                (1)
                    case "$gstatus" in 
                        (.A) ((added++));;
                        (.D) ((deleted++));;
                        (.M) ((modified++));;
                        (AA|A.) ((added++)); sadded=1;;
                        (DD|D.) ((deleted++)); sdeleted=1;;
                        (MM|M.) ((modified++)); smodified=1;;
                    esac
                    ;;
                (2)
                    case "$gstatus" in
                        R.|RM) ((renamed++));;
                    esac
                    ;;
            esac
        done < <(git status --porcelain=v2 --untracked-files=no --ignored=no --branch . 2>/dev/null)

        psvar[3]="$branch"
        psvar[4]="$modified"
        psvar[5]="$smodified"
        psvar[6]="$deleted"
        psvar[7]="$sdeleted"
        psvar[8]="$added"
        psvar[9]="$sadded"
        psvar[10]="$renamed"
        psvar[11]="$ahead"
        psvar[12]="$behind"
    else 
        psvar[3]=""
    fi
}


# left part of prompt, git part
PROMPT="%(3V.%F{8}%K{8}%F{white}󰘬 %(11V.%F{green}+%11v .)%(12V.%F{red}-%12v .)%F{white}%3v%(8V. %F{yellow}~%8v%(9V>.>).)%(4V. %F{yellow}~%4v%(5V>.>).)%(7V. %F{yellow}~%7v%(8V>.>).)%(10V. %F{magenta}->%10v.) .)"
# left part of prompt, current directory
PROMPT+="%B%F{%2v}%S%k󰉋 %(4~|%-1~/…/%24<..<%2~%<<|%4~)%s%f%b "
# right part of prompt, flags and previous command status
RPROMPT="%(14V.%F{8}[ro] .)%(13V.%F{8}[ venv] .)%F{8}%K{8}%f󱎫 %1v %(1j.%F{white}%j& %f.)%F{%(?.12.%(130?.yellow.red))}%k%S%(?.󰄬 %?.%(130?.int.󰅖 %?))%s"
function precmd {
    # dont print a new time on every single <cr>, just if a command ran
    if (( _PROMPTTIMER)); then
        local elapsed_ms=$[ ( $EPOCHREALTIME-$_PROMPTTIMER )* 1000 ] elapsed
        if (( elapsed_ms > 60000 )) {
            # print everything over a minute as MM:SS
            printf -v elapsed "%02.0f:%02.0f" $[ ($elapsed_ms/1000.0) / 60 ] $[ ($elapsed_ms/1000.0) % 60 ]
        } elif (( elapsed_ms >= 100 )) {
            printf -v elapsed "%.2fs" $[ $elapsed_ms/1000.0 ]
        } else  {
            printf -v elapsed "%.2fms" $elapsed_ms
        }
        psvar[1]=$elapsed
        # format: <elapsed time> <jobs? and if yes <count>&> <exit code with symbol> <time it took>
    fi
    # set the title
    print -Pn "\e]0;zsh%(1j. %j&.): %~\a"
    if [[ -n "$VIRTUAL_ENV" ]]; then
        psvar[13]=1
    else
        psvar[13]=""
    fi
    if [[ ! -w "$PWD" ]]; then
        psvar[14]=1
    else
        psvar[14]=""
    fi
    _update_git_status
    _PROMPTTIMER=0
}

# Prompt for nested things:
PS2="%F{8}%K{8}%f󰅪 %_%k%F{8}%f "
#
# sudo prompt
export SUDO_PROMPT="$(print -P "\n%B%F{red}%S sudo%s%f%b ")"

# only the default, i have a couple more functions planed for this
TIMEFMT="User   %U
Kernel %S
Time   %E"

# disable python venv automatic prompt changing
export VIRTUAL_ENV_DISABLE_PROMPT=1

# explicitly update it on first run
_update_git_status
