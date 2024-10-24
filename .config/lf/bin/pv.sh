#!/bin/bash
IFS='
'
if [[ "$1" == "fzf" ]]; then
    file="$2"
    w=$FZF_PREVIEW_COLUMNS
    h=$FZF_PREVIEW_ROWS
    x=$FZF_PREVIEW_LEFT
    y=$FZF_PREVIEW_TOP
else
    file=$1
    w=$2
    h=$3
    x=$4
    y=$5
fi
LINES=$h
COLUMNS=$w
giveOpenHint(){
    printf "\033[33m $1 \033[0m \n\n"
}
Title(){
    printf "\033[33m$1 \033[0m\n\n"
}
# gives infos, e.g. no previewer
giveOpenInfo(){
    printf "\033[34m $1 \033[0m \n\n"
}
# warns, not used for anything rn
giveOpenWarn(){
    printf "\033[31;1m $1 \033[0m \n\n"
}
# checks if we can even read the file, if not exits and tells the user who can read it.
if ! [ -r "$file" ]
then
    printf "\033[31;1m You don't have read access to the file $file.\n\033[0m"
    perms=$(lsd --blocks permission --color=always $file)
    owner=$(stat -c "%U" $file)
    group=$(stat -c "%G" $file)
    printf "Permissions: $perms
\033[32mOwner: $owner
\033[34mGroup: $group"
    exit 1
fi
if [ -x "$file" ]
then
    giveOpenHint "Use ee or eE to execute"
fi
# hints at a way to open files
# creates a cache directory for pdfs converted to images
mkdir -p $HOME/.cache/lf 
cachedir="$HOME/.cache/lf"
# cleans up the name of the file
filename=$(basename "$(echo "$file" | tr ' ' '_')")
case "$(file --dereference --brief --mime-type -- "$file")" in
    application/*pdf) #convert to png and then view using kitty
        if [ ! -f "$cachedir/$filename.png" ]; then
            pdftoppm -f 1 -l 1 "$file" >> "$cachedir/$filename.png"
        fi
        kitten icat --silent --stdin no --transfer-mode memory --place "${w}x${h}@${x}x${y}" "$cachedir/$filename.png" < /dev/null > /dev/tty
        exit 1
    ;;
    image/*|t) #just kitty
        if [ $(stat -c %s "$file") -gt 31457280 ]
        then
            giveOpenInfo "Images larger than 30mb won't be displayed."
            exit 1
        fi
        identify -format 'Format: %m\nSize: %wx%h\nColor Depth: %z Bits per Pixel\n' "$file"
        kitten icat --silent --stdin no --transfer-mode memory --place "${w}x$((h-4))@${x}x$((y+4))" "$file" < /dev/null > /dev/tty
        exit 1
    ;;
    application/postscript)
        if [ $(stat -c %s "$file") -gt 31457280 ]
        then
            giveOpenInfo "Postscript Files larger than 30mb won't be displayed."
            exit 1
        fi
        kitten icat --silent --stdin no --transfer-mode memory --place "${w}x${h}@${x}x${y}" "$file" < /dev/null > /dev/tty
        exit 1
    ;;  
    video/*)
        if [ ! -f "$cachedir/$filename.png" ]; then
            ffmpegthumbnailer -s 0 -m -i "$file" -o "$cachedir/$filename.png"
        fi
        kitten icat --silent --stdin no --transfer-mode memory --place "${w}x${h}@${x}x${y}" "$cachedir/$filename.png" < /dev/null > /dev/tty
        exit 1
    ;;
    *opendocument*) #libreoffice stuff as text
        odt2txt "$1" 
        exit 1
    ;;
    *x-iso9660-image) #show contents of iso and tells us how to mount it
        giveOpenHint "Use <oDm> and <oDu> to mount and unmount iso filesystem images"
        iso-info $file -f --no-header
        exit 1
    ;;
    # don't open binary files
    *octet-stream)
        printf "\033[7mBinary\033[0m\n"
        xxd -R always -u -c 12 "$1"
        exit 1
    ;; 
    application/x-sharedlib|application/x-pie-executable|application/x-executable|application/x-object)
        giveOpenInfo "ELF executable/library"
        readelf -hn $file
        exit 1
    ;;
    text/* | */xml  |application/javascript) #use bat for text 
        COLORTERM=truecolor bat -pf --wrap=character --terminal-width=$(($2-4)) -f --number "$file"
        exit 1
    ;;
    application/json)
        jq -C < "$file"
        exit 1
        ;;
    inode/x-empty|application/x-empty)
        printf "\033[7mEmpty"
        exit 1
    ;;
    font/*|application/vnd.ms-opentype)
        fc-query "$file"
        exit 1;;
    audio/*)
        output_file=$(mktemp)
        mediainfo --Output=JSON "$file"|jq -r '.media.track[0]|.Title // "-" , .Album // "-" , .Album_Performer // "-" , .Genre // "-" , .Format // "-" , .Duration, .OverallBitRate'|tr '\n' '\t' > "$output_file"
        IFS="$(printf '\t')" read -r title album performer genre format duration overall_bitrate < "$output_file"
        seconds=${duration%.*}
        mins=$((seconds / 60))
        seconds=$((seconds % 60))
        ffmpeg -i "$file" -an -vcodec mjpeg -f image2pipe -|kitty +kitten icat --stdin=yes --transfer-mode memory --place "${w}x$((h-7))@${x}x$((y+7))" > /dev/tty
        printf "Title: %s\nAlbum: %s\nArtist: %s\nGenre: %s\nFormat: %s\nBitrate: %skbps\n" "${title}" "${album}" "${performer}" "${genre}" "${format}" $((overall_bitrate/1000))
        printf "Length: %02d:%02d\n" $mins $seconds
        rm "$output_file"
        exit 1;;
    application/vnd.flatpak.ref)
        giveOpenInfo "Flatpak Reference File"
        . "$file"
        printf "App: %s\n" "$Name"
        exit 1
        ;;

esac
case $file in #archives
    *.a|*.ace|*.alz|*.arc|*.arj|*.bz|*.bz2|*.cab|*.cpio|*.deb|*.gz|*.jar|*.lha|*.lz|*.lzh|*.lzma|*.lzo|*.rpm|*.rz|*.7z|*.t7z|*.tar|*.tbz|*.tbz2|*.tgz|*.tlz|*.txz|*.tZ|*.tzo|*.war|*.xpi|*.xz|*.Z|*.zip|*.apk|*.rar)
    giveOpenHint "Use <ae> to extract archive"
    bsdtar --list --file "$1" #|awk '{print $3"  "$4"  "$5"   "$6}' - |column -t
    exit 1
    ;;
esac
# if we don't know the file yet
giveOpenInfo "No previewer configured for files of type:
$(file --dereference --brief --mime-type -- "$1")"
