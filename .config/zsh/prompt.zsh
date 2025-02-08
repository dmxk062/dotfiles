psvar=(
    0             # 1 time of previous command
    "cyan"        # 2 color of prompt
    ""            # 3 git branch
    ""            # 4 git modified
    ""            # 5 git deleted
    ""            # 6 git added
    ""            # 7 git renamed
    ""            # 8 git ahead
    ""            # 9 git behind
    ""            # 10 current dir readable
    "12"          # 11 color based on return status
    ""            # 12 symbol/text to be used for return status
)


# change the color of the prompt based on mode
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
    git check-ignore -q . 2>/dev/null
    # returns 0 if dir ignored and 1 if not but still git
    if (($? == 1)); then
        local type gstatus submod file
        local modified="" deleted="" added="" renamed="" smodified="" sdeleted="" sadded="" _branch branch="" remote="" ahead="" behind=""
        git status --porcelain=v2 --untracked-files=no --ignored=no --branch . 2>/dev/null | while read -r type gstatus submod _ _ _ file; do
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
                            [[ "$ahead" == -* ]] && behind="${ahead#-}"

                            [[ "$ahead" == 0 ]] && ahead=""
                            [[ "$behind" == 0 ]] && behind=""
                            ;;
                    esac
                    ;;
                (1)
                    case "$gstatus" in 
                        (.A) ((added++));;
                        (.D) ((deleted++));;
                        (.M) ((modified++));;
                        (AA|A.) ((added++)); sadded=.;;
                        (DD|D.) ((deleted++)); sdeleted=.;;
                        (MM|M.) ((modified++)); smodified=.;;
                    esac
                    ;;
                (2)
                    case "$gstatus" in
                        R.|RM) ((renamed++));;
                    esac
                    ;;
            esac
        done

        printf "%s;%s;%s;%s;%s;%s;%s\n" \
            "$branch" "$modified$smodified" "$deleted$sdeleted" "$added$sadded" "$renamed" "$ahead" "$behind"
    else 
        echo
    fi
}


# left part of prompt, git part
PROMPT="%F{8}╭%(3V.%F{8}%K{8}%F{white}󰘬 %(8V.%F{green}+%8v .)%(9V.%F{red}-%9v .)%F{white}%3v%(6V. %F{green}+%6v.)%(4V. %F{yellow}~%4v.)%(5V. %F{red}-%5v.)%(7V. %F{magenta}->%7v.) .)"
# left part of prompt, current directory
PROMPT+="%B%F{%2v}%S%k󰉋 %(6~|%-1~/…/%24<..<%3~%<<|%6~)%s%f%b%(10V.%F{8} [ro] .)
%F{8}╰╴%f "

# right part of prompt, previous command status
# HACK: draw right prompt one line higher
RPROMPT="%{$(echotc UP 1)%}%(1j.%F{8}[& %j] %f.)%F{8}%K{8}%f󱎫 %1v %F{%11v}%k%S%12v%s%{$(echotc DO 1)%}"

declare -A _exitcolors=(
    [0]=12
    [130]=yellow
    [147]=blue
    [148]=blue
)

# run process for git status asynchronously
_PROMPTPROC=0

# use a pseudo anonymous pipe
# TODO: find a way to avoid non shell built ins
mkfifo "$ZCACHEDIR/prompt_$$"
exec {_PROMPTFD}<> "$ZCACHEDIR/prompt_$$"
unlink "$ZCACHEDIR/prompt_$$" &!

function precmd {
    local exitc=$?

    if ((_PROMPTPROC != 0)); then
        kill -s HUP $_PROMPTPROC >/dev/null 2>&1 || :
    fi

    ( _update_git_status >&$_PROMPTFD
        kill -s USR1 $$ >/dev/null 2>&1
    ) &!
    _PROMPTPROC=$!

    if ((exitc > 128 && exitc < 256)); then
        local signame="${signals[exitc-127]:l}"
        signame="${signame:-$exitc}"
        psvar[12]="! $signame"
    else 
        if ((! exitc)); then
            psvar[12]="󰄬 0"
        else
            psvar[12]="󰅖 $exitc"
        fi
    fi
    psvar[11]="${_exitcolors[$exitc]}"
    if [[ -z "${psvar[12]}" ]]; then
        psvar[11]=red
    fi

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
    fi
    # set the title
    print -Pn "\e]0;zsh%(1j. %j&.): %~\a"
    if [[ ! -w "$PWD" ]]; then
        psvar[10]=1
    else
        psvar[10]=""
    fi
    _PROMPTTIMER=0
}

function TRAPUSR1 {
    local -a tmp
    IFS=";" read -u $_PROMPTFD -rA tmp
    psvar[3]=$tmp[1]
    psvar[4]=$tmp[2]
    psvar[5]=$tmp[3]
    psvar[6]=$tmp[4]
    psvar[7]=$tmp[5]
    psvar[8]=$tmp[6]
    psvar[9]=$tmp[7]

    _PROMPTPROC=0

    zle -I && zle reset-prompt
}

# Prompt for nested things:
PS2="%F{8}%_ │%f "

# sudo prompt
print -P -v SUDO_PROMPT "\n%F{8}╭%B%F{red}%S sudo%s%f%b
%F{8}╰╴%f "
export SUDO_PROMPT

# only the default, i have a couple more functions planed for this
TIMEFMT="User   %U
Kernel %S
Time   %E"

# disable python venv automatic prompt changing
export VIRTUAL_ENV_DISABLE_PROMPT=1
