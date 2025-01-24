#!/usr/bin/env zsh

CACHEDIR="$XDG_CACHE_HOME/lf"
if ! [[ -d "$CACHEDIR" ]] { mkdir -p "$CACHEDIR" }


FILE=$1
W=$2
H=$3
X=$4
Y=$5
LINES="$H"
COLUMNS="$W"

IMAGE_SIZE="600x400"

function display_image {
    kitten icat --silent --stdin no --transfer-mode memory --place "${W}x$[H-${2:-0}]@${X}x$[Y+${2:-0}]" "$1" < /dev/null > /dev/tty
}

function info {
    print -P "%F{8}%F{white}%K{8}${1}%K{black}%F{8}\e[0m\n"
}

function separator {
    printf "%.0s-" {1..$W}
}

function create_cache {
    local pathn="${1:h4}"
    local pathn="${pathn//\//.}"
    local pathe="${1:t4}"
    local pathe="${pathe//\//.}"
    print -- "$CACHEDIR/${pathn:1}.${pathe}${2}"
}


if ! [[ -r "$FILE" ]] {
    print -P "%SPermission Denied"
    exit 1
}

MIMETYPE="$(file --dereference --brief --mime-type -- "$FILE")"

case "$MIMETYPE" in
    application/pdf) 
        tmpfile="$(create_cache "${FILE}" ".png")"
        if ! [[ -f "$tmpfile" ]] {
            pdftoppm -f 1 -l 1 -png "$FILE" >> "$tmpfile"
        }
        display_image "$tmpfile"
        exit 1
        ;;

    image/*)
        tmpfile="$(create_cache "${FILE}")"
        datafile="$(create_cache "$FILE" ".desc")"
        if [[ ! -f "$tmpfile" ]] {
            magick convert "$FILE" -resize "$IMAGE_SIZE" "$tmpfile"&
            identify -format 'Format: %m\nResolution: %wx%h\nColor Depth: %z Bits per Pixel\nTaken by: %[EXIF:Make] %[EXIF:Model]\n' "$FILE" > "$datafile"&
            wait
        }
        cat "$datafile"
        display_image "$tmpfile" 6
        exit 1
        ;;

    video/*)
        tmpfile="$(create_cache "${FILE}" ".png")"
        datafile="$(create_cache "${FILE}" ".desc")"
        if ! [[ -f "$tmpfile" ]] {
            (
                IFS=$'\t' read -r audio_format audio_bitrate video_format video_bitrate video_resolution video_framerate video_duration < <(mediainfo --output=JSON "$FILE" \
                    |jq -r '([.media.track|.[]|select(."@type" == "Video")][0]) as $video | ([.media.track|.[]|select(."@type" == "Audio")][0]) as $audio|
                    "\($audio.Format)\t\($audio.BitRate)\t\($video.Format)\t\($video.BitRate)\t\($video.Width)x\($video.Height)\t\($video.FrameRate)\t\($video.Duration)"'
                )
                seconds="${video_duration%.*}"
                minutes=$[seconds / 60]
                hours=$[minutes / 60]
                minutes=$[minutes % 60]
                seconds=$[seconds % 60]
                audio_bitrate=$[audio_bitrate / 1000]
                video_bitrate=$[video_bitrate / 1000000]
                ((audio_bitrate == 0)) && audio_bitrate="unknown bitrate" || audio_bitrate="${audio_bitrate}kbps"
                ((video_bitrate == 0)) && video_bitrate="unknown bitrate" || video_bitrate="${video_bitrate}mbps"
                if [[ "$audio_format" == "null" ]]; then
                    audio="none"
                else
                    audio="$audio_format (${audio_bitrate})"
                fi
                printf "Audio: %s\nVideo: %s (%s)\nResolution: %s\nFramerate: %sfps\nRuntime: %02d:%02d:%02d\n" \
                    "$audio" "$video_format" "$video_bitrate" "$video_resolution" "$video_framerate" "$hours" "$minutes" "$seconds" \
                > "$datafile"
            )&
            ffmpegthumbnailer -s 512 -m -i "$FILE" -o "$tmpfile"&

            wait
        }
        cat "$datafile"
        display_image "$tmpfile" 6
        exit 1
        ;;

    audio/*)
        tmpfile="$(create_cache "${FILE}" ".png")"
        datafile="$(create_cache "${FILE}" ".desc")"
        if [[ ! -f "$tmpfile" ]] {
            (
                IFS=$'\t' read -r title album artist genre format duration bitrate < <(mediainfo --output=JSON "$FILE" \
                    |jq -r '.media.track[0]|"\(.Title // "-")\t\(.Album // "-")\t\(.Performer // "-")\t\(.Genre // "-")\t\(.Format)\t\(.Duration)\t\(.OverallBitRate)"')
                seconds="${duration%.*}"
                minutes=$[seconds / 60]
                seconds=$[seconds % 60]
                local -a genres=("${(@s: /:)genre}")
                local genre_str="${(j:,:)genres}"
                printf "Title: %s\nArtist: %s\nAlbum: %s\nGenre(s): %s\nFormat: %s\nBitrate: %skbps\nDuration: %02d:%02d"  \
                    "${title}" "${artist}" "${album}" "${genre_str}" "${format}"  $[bitrate / 1000] $minutes $seconds \
                > "$datafile"
            )&
            ffmpegthumbnailer -s 512 -m -i "$FILE" -o "$tmpfile"&
            wait
        }
        cat "$datafile"
        display_image "$tmpfile" 8
        exit 1
        ;;


    *x-iso9660-image)
        datafile="$(create_cache "${FILE}" ".desc")"
        if [[ ! -f "$datafile" ]]; then
            local keywords=1 application creator publisher volume
            local -a files
            iso-info --no-header -i "$FILE"|while read -r line; do
                if ((keywords)) && [[ "$line" =~ ^.*:.*$ ]]; then
                    IFS="${IFS}:" read -r key value <<< "$line"
                    case "$key" in
                        Application) application="$value";;
                        Preparer) creator="$value";;
                        Publisher) publisher="$value";;
                        Volume) [[ "$value" != "Set"* ]] && volume="$value";;
                    esac
                elif [[ "$line" == "ISO-9660 Information" ]]; then
                    keywords=0
                elif ! ((keywords)); then
                    read -r size file <<< "$line"
                    files+=("$file")
                fi
            done
            print "Name: ${application:--}\nCreated by: ${creator:--}\nPublisher: ${publisher:--}\nVolume: ${volume:--}\n\nFile Listing:" > "$datafile"
            print "${(j:\n:)files}" >> "$datafile"
        fi
        cat "$datafile"
        exit 1
        ;;

    *opendocument*|application/vnd.openxmlformats-officedocument.*)
        tmpfile="$(create_cache "$FILE" ".png")"
        if ! [[ -f "$tmpfile" ]] {
            libreoffice --convert-to pdf "$FILE" --outdir "$CACHEDIR" >/dev/null 2>&1
            outfile="$CACHEDIR/${FILE:t}" 2>/dev/null
            outfile="${outfile%.*}.pdf" 2>/dev/null
            pdftoppm -f 1 -l 1 -png "$outfile" >> "$tmpfile" 2>/dev/null
            rm "$outfile"
        }
        display_image "$tmpfile"
        exit 1
        ;;

    text/*|*/xml|application/javascript|application/pgp-signature|application/x-setupscript|application/x-wine-extension-ini)
        COLORTERM=truecolor bat -pf --wrap=character --terminal-width=$[W-4] -f --number \
            --line-range 1:$[LINES - 2] "$FILE"
        exit 1
        ;;

    application/json)
        jq -C < "$FILE"
        exit 1
        ;;

    *octet-stream)
        print -P "%SBinary\e[0m"
        xxd -a -R always -c $[(COLUMNS / 6) + 1] -u -l $[(( (COLUMNS / 6) + 1) * LINES) + 256 ] "$FILE"
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
    application/x-object)
        info "󰈮 Object File"
        local -a funcs undef vars
        while read -r symbol type _; do
            case $type in
                T)
                    funcs+="$symbol";;
                U)
                    undef+="$symbol";;
                D)
                    vars+="$symbol";;
            esac
        done <<< "$(nm -g --format=posix "$FILE")"
        print -- "$#funcs Function(s):
${(j:, :)funcs}

$#vars Variable(s):
${(j:, :)vars}

$#undef Undefined Symbol(s):
${(j:, :)undef}"|fmt -sw $((W-4))

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
                RuntimeRepo)
                    repo=$value;;
            esac
        done < "$FILE"
        print "$name: $desc\nVersion: $ver\nHomepage: $url\nRepo: $repo"
        exit 1
        ;;

    font/sfnt|application/vnd.ms-opentype)
        local example_text="ABCDEFGHIJKLMNOPQRSTUVWXYZ
abcdefghijklmnopqrstuvwxyz
01234567890 $€£¥
() {} [] <> \\\|/ +-*= ¿?¡! .,:; &%#@^
The quick brown fox jumps over the lazy dog.
Zwölf Boxkämpfer jagen Viktor quer über den großen Sylter Deich.
"
        tmpfile="$(create_cache "${FILE}" ".png")"
        datafile="$(create_cache "${FILE}" ".desc")"
        if ! [[ -f "$tmpfile" ]] {
            convert -background transparent -fill '#eceff4' -font "$FILE" \
                -pointsize 12 label:"$example_text" \
                "$tmpfile" &
            fc-scan \
                --format="Name: %{fullname}\nFamily: %{family}\nPostscript: %{postscriptname}\nStyle(s): %{style}\n" \
                -- "$FILE" > "$datafile"&
            wait
        }
        cat "$datafile"
        display_image "$tmpfile" 5
        exit 1
        ;;

    *)
        info "󰈔 ${MIMETYPE}"
        exit 1
        ;;
esac

