# we *need* EPOCHREALTIME for the prompt to be accurate
zmodload zsh/datetime

declare -A _promptvars=(
    [color]="cyan"
    [timer]=0
    [vcs_branch]=""
    [vcs_remote]=""
    [vcs_ahead]=0
    [vcs_behind]=0
    [vcs_modified]=0
    [vcs_deleted]=0
    [vcs_added]=0
    [vcs_active]=0
)
# directly set the hooks instead of just adding to the hook, so ours runs first
function preexec {
    _promptvars[timer]=$EPOCHREALTIME
}

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
    _promptvars[color]="$mode_colors[$ZVM_MODE]"
    _update_prompt
}

function _update_git_status {
    # only update if inside a git dir that isnt ignored
    git check-ignore . &> /dev/null
    # returns 0 if dir ignored and 1 if not but still git
    if (($? == 1)) {
        _promptvars[vcs_active]=1
        local type gstatus submod hname iname score file _
        local modified=0 deleted=0 added=0 _branch branch="" remote="" ahead=0 behind=0
        while read -r type gstatus submod hname iname score file; do
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
                            ;;
                    esac
                    ;;
                (1)
                    case "$gstatus" in 
                        (*A*) ((added++));;
                        (*D*) ((deleted++));;
                        (*M*) ((modified++));;
                    esac
                    ;;
                (2)
                    # Nothing for moved/renamed for now
                    ;;
            esac
        done < <(git status --porcelain=v2 --untracked-files=no --ignored=no --branch . 2>/dev/null)
        _promptvars[vcs_branch]="$branch"
        _promptvars[vcs_remote]="$upstream"
        _promptvars[vcs_modified]="$modified"
        _promptvars[vcs_deleted]="$deleted"
        _promptvars[vcs_added]="$added"
        _promptvars[vcs_ahead]="$ahead"
        _promptvars[vcs_behind]="$behind"
    } else {
        _promptvars[vcs_active]=0
    }
}

function chpwd {
    _update_git_status
}

function _update_prompt {
    PROMPT="%B%F{$_promptvars[color]}%S%k󰉋 %(4~|%-1~/…/%24<..<%2~%<<|%4~)%s%f%b "
    if ((_promptvars[vcs_active])) {
        local modified added deleted ahead behind
        if ((_promptvars[vcs_modified] > 0)) {
            modified=" %F{yellow}~$_promptvars[vcs_modified]"
        }
        if ((_promptvars[vcs_added] > 0)) {
            added=" %F{green}+$_promptvars[vcs_added]"
        }
        if ((_promptvars[vcs_deleted] > 0)) {
            deleted=" %F{red}-$_promptvars[vcs_deleted]"
        }
        if ((_promptvars[vcs_ahead] > 0)) {
            ahead="%F{green}+$_promptvars[vcs_ahead] "
        }
        if ((_promptvars[vcs_behind] > 0)) {
            ahead="%F{red}-$_promptvars[vcs_behind] "
        }
        PROMPT="%b%F{8}%K{8}%F{white}󰘬 ${ahead}${behind}%F{white}${_promptvars[vcs_branch]}${added}${modified}${deleted}${ahead_behind}%K{8} $PROMPT"
    }
}


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
        # format: <elapsed time> <jobs? and if yes <count>&> <exit code with symbol> <time it took>
        RPROMPT="%F{8}%K{8}%f󱎫 ${elapsed} %(1j.%F{cyan}%j& %f.)%(?.%F{green}.%F{red})%k%S%(?.󰄬 %?.󰅖 %?) %s"
    fi
    # set the title
    print -Pn "\e]0;zsh%(1j. %j&.): %~\a"
    if [[ -n "$VIRTUAL_ENV" ]] {
        RPROMPT="%B%F{$ZSH_COLORS_RGB[orange]}%S venv%s%b%f ${RPROMPT}"
    }
    _promptvars[timer]=0
    _update_git_status
    _update_prompt
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
