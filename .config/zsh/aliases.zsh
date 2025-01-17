alias \
    updategrub="sudo grub-mkconfig -o /boot/grub/grub.cfg" \
    bc="bc -l" \
    svim="sudoedit" \
    sv="sudoedit" \
    nv="nvim -b" \
    yay="yay --editmenu --devel" \
    mpv="mpv --hwdec=auto" \
    q="exit" \
    x="exit" \
    rm="rm -i" \
    ls='ls --color=auto --hyperlink=auto' \
    ll='lsd -l --hyperlink=auto' \
    lla='lsd -lA --hyperlink=auto' \
    llo='lsd -l --permission=octal --hyperlink=auto' \
    llao='lsd -lA --permission=octal --hyperlink=auto' \
    la='lsd -A --hyperlink=auto' \
    lar='lsd -A --tree --depth 3  --hyperlink=auto' \
    l='lsd --hyperlink=auto' \
    grep='grep --color=auto' \
    fdd="fd -t d" \
    fdf="fd -t f" \
    g="git" \

alias '#'="noglob qalc" # do math directly on the cmdline

# nice to have redirections
alias \
    -g "@quiet"=">/dev/null 2>&1" \
    -g "@err2out"="2>&1" \
    -g "@out2err"=">&2" \
    -g '@noerr'="2>/dev/null" \
    -g "@noout"=">/dev/null"

alias \
    '@raw'="noglob" \
    ':tab'="IFS=$'\t'" \
    ':colon'="IFS=':'" \
    ':semic'="IFS=';'" \
    ':lf'="IFS=$'\n'" \
    ':eq'="IFS='='"

TAB=$'\t'
FALSE=1
TRUE=0

if [[ -n "$NVIM" ]]; then
    alias nv=nvr \
        sp="nvr -o" \
        vsp="nvr -O" \
        tab="nvr -p"
fi
