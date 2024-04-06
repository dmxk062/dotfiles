#!/usr/bin/env zsh



CACHEDIR="$XDG_CACHE_HOME/lf"
if ! [[ -d "$CACHEDIR" ]] { mkdir -p "$CACHEDIR" }

MAX_IMAGE_SIZE=20971520

FILE=$1
W=$2
H=$3
X=$4
Y=$5
LINES="$H"
COLUMNS="$W"






function display_image {
    kitten icat --silent --stdin no --transfer-mode memory --place "${W}x${H}@${X}x${Y}" "$1" < /dev/null > /dev/tty
}

function info {
    print -P "\e[90m%F{white}\e[100m${1}\e[40m\e[90m\e[0m\n"

}

function create_cache {
    local pathn="${1:h4}"
    local pathn="${pathn//\//.}"
    local basen="${1:t}"
    print -- "$CACHEDIR/$pathn.$basen${2}"
}


if ! [[ -r "$FILE" ]] {
    read -r owner group perms <<< $(stat -c "%U %G %A" "$FILE")
    print -P "%B%F{red}Permission Denied%b%F{white}

Owner: %F{magenta}$owner%F{white}
Group: %F{cyan}$group%F{white}
Perms: %F{yellow}$perms%F{white}"
    exit 0
    
}

MIMETYPE="$(file --dereference --brief --mime-type -- "$FILE")"

case "$MIMETYPE" in
    application/pdf) 
        tmpfile="$(create_cache "${FILE}" ".ppm")"
        if ! [[ -f "$tmpfile" ]] {
            pdftoppm -f 1 -l 1 "$FILE" >> "$tmpfile"
        }
        display_image "$tmpfile"
        exit 1
        ;;

    image/*)
        size=$(stat -c %s "$FILE")
        if ((size > MAX_IMAGE_SIZE)) {
            print -P -- "%F{blue}󰋽 Image is greater than 20mb"
        } else {
            identify -format 'Format: %m\nSize: %wx%h\nColor Depth: %z Bits per Pixel\n' "$FILE"
            H=$[H-4]
            Y=$[Y+4]
            display_image "$FILE"
        }
        exit 1
        ;;

    video/*)
        tmpfile="$(create_cache "${FILE}" ".png")"
        if ! [[ -f "$tmpfile" ]] {
            ffmpegthumbnailer -s 512 -m -i "$FILE" -o "$tmpfile"
        }
        display_image "$tmpfile"
        exit 1
        ;;

    audio/*)
        local -a fields
        IFS=$'\n' fields=($(mediainfo --output=JSON "$FILE" \
            |jq -r '.media.track[0]|.Title // "-", .Album // "-", .Album_Performer // "-", .Genre // "-", .Format // "-", .Duration, .OverallBitRate'))
        seconds="${fields[6]%.*}"
        minutes=$[seconds / 60]
        seconds=$[seconds % 60]
        tmpfile="$(create_cache "$FILE" ".png")"
        if ! [[ -f "$tmpfile" ]] {
            ffmpegthumbnailer -s 512 -m -i "$FILE" -o "$tmpfile"
        }
        ((H-=7))
        ((Y+=7))
        local -a genres=("${(@s: /:)fields[4]}")
        local genre_str="${(j:,:)genres}"
        printf "Title: %s\nArtist: %s\nAlbum: %s\nGenre(s): %s\nFormat: %s\nBitrate: %skbps\nDuration: %02d:%02d"  \
            "${fields[1]}" "${fields[3]}" "${fields[2]}" "${genre_str}" "${fields[5]}"  $[fields[7] / 1000] $minutes $seconds
        display_image "$tmpfile"
        exit 1
        ;;


    *x-iso9660-image)
        info "󰗮 Disk Image"
        iso-info --no-header "$FILE" -f|tail -n+10|while read -r num file; do
            print -- "$file"
        done
        exit 1
        ;;

    *opendocument*)
        tmpfile="$(create_cache "$FILE" ".ppm")"
        if ! [[ -f "$tmpfile" ]] {
            libreoffice --convert-to pdf "$FILE" --outdir "$CACHEDIR"
            outfile="$CACHEDIR/${FILE:t}"
            outfile="${outfile:0:-3}pdf"
            pdftoppm -f 1 -l 1 "$outfile" >> "$tmpfile"
        }
        display_image "$tmpfile"
        exit 1
        ;;

    text/* | */xml | application/javascript)
        case $MIMETYPE in
            text/*)
                name="${MIMETYPE//text\//}";;
            *)
                name="${MIMETYPE}";;
        esac
        info "󰈔 $name"
        COLORTERM=truecolor bat -pf --wrap=character --terminal-width=$((W-4)) -f --number \
            --line-range 1:$[LINES - 2] "$FILE"
        exit 1
        ;;

    application/json)
        jq -C < "$FILE"
        exit 1
        ;;

    *octet-stream)
        print -P "%SBinary\e[0m"
        xxd -R always -c $[(COLUMNS / 6) + 1] -u -l $[( (COLUMNS / 6) + 1) * LINES] "$FILE"
        exit 1
        ;;

    inode/x-empty|application/x-empty)
        print -P "%SEmpty\e[0m"
        exit 1
        ;;

    application/x-archive|application/x-cpio|application/x-tar|application/x-bzip2|application/gzip|application/x-lzip|application/x-lzma|application/x-xz|application/x-7z-compressed|application/vnd.android.package-archive|application/vnd.debian.binary-package|application/java-archive|application/x-gtar|application/zip)
        info "󰛫 ${MIMETYPE//application\//} Archive"
        bsdtar --list --file "$FILE"
        exit 1
        ;;
    application/x-rar-compressed|application/x-rar)
        info "󰛫 rar Archive"
        local flag=0
        unrar-free -t "$FILE"|tail -n+10|while read -r line; do
            if ((flag == 0)){
                print "$line"
                flag=1
            } else {
                flag=0
            }
            done
        exit 1
        ;;  
    application/x-pie-executable|application/x-executable|application/x-sharedlib)
        case "$MIMETYPE" in 
            application/x-pie-executable|application/x-executable)
                name="Executable"
                ;;
            application/x-sharedlib)
                name="Library"
                ;;
        esac
        info "󰣆 ELF $name"
        readelf -h "$FILE"| while IFS="$IFS:" read -r field value; do
            case $field in
                Class)
                    print "Type: $value";;
                OS/ABI)
                    print "ABI : $value";;
                Machine)
                    print "Arch: $value";;
                Type)
                    print "Type: $value";;
            esac
        done
        local -a libs=($(objdump -p -- "$FILE"|grep NEEDED|while read -r _ lib; do print -- "$lib"; done))
        print "\nLinked against:
${(j:
:)libs[@]}"
        exit 1
        ;;

    application/vnd.flatpak.ref)
        info "󰏖 Flatpak Package Definition"
        ver=unknown
        while IFS='=' read -r key value; do
            case "$key" in
                Name)
                    appid=$value;;
                Title)
                    name=$value;;
                Version)
                    ver=$value;;
                Description)
                    desc=$value;;
                Url)
                    url=$value;;
                Icon)
                    icon_url=$value;;
                RuntimeRepo)
                    repo=$value;;
            esac
        done < "$FILE"
        tmpfile="$(create_cache "$FILE" "svg")"
        if ! [[ -f "$tmpfile" ]] {
            curl "$icon_url" > "$tmpfile"
        }
        print "$name\n$desc\nVersion: $ver\nHomepage: $url\nRepo: $repo"
        ((H-=8))
        ((Y+=8))
        display_image "$tmpfile"

        exit 1
        ;;

    font/sfnt|application/vnd.ms-opentype)
        local example_text="ABCDEFGHIJKLMNOPQRSTUVWXYZ
abcdefghijklmnopqrstuvwxyz
01234567890
(){}[]!@#$%^&*-+_=/|\\\><,.:;\"\'
The quick brown fox jumps over the lazy dog."
        tmpfile="$(create_cache "${FILE}" ".png")"
        if ! [[ -f "$tmpfile" ]] {
            convert -background transparent -fill '#eceff4' -font "$FILE" \
                -pointsize 24 label:"$example_text" \
                "$tmpfile"
        }
        # fc-scan --format="%{fullname}\nStyle: %{style}\nScalable: %{scalable}\nVariable: %{variable}\nSymbols: %{symbol}\nHinting: %{fonthashint}\n\n" -- "$FILE"
        # ((H-=8))
        # ((Y+=8))
        display_image "$tmpfile"

        exit 1
        ;;

    *)
        info "󰈔 ${MIMETYPE}"
        exit 1
        ;;

esac

