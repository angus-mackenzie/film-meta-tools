#!/usr/bin/env bash

# Constants
declare -rx DEFAULT_COPYRIGHT="© Angus Mackenzie"
declare -rx SUSPICIOUS_YEARS=("1988" "1989" "1990")
declare -rx IMAGE_EXTENSIONS="[jJ][pP][gG]|[jJ][pP][eE][gG]|[tT][iI][fF][fF]|[rR][aA][wW]|[cC][rR]2|[nN][eE][fF]|[aA][rR][wW]"

# Shared functions
is_suspicious_year() {
    local year="$1"
    [[ ${SUSPICIOUS_YEARS[*]} =~ ${year} ]]
}
export -f is_suspicious_year

is_image_file() {
    local file="$1"
    [[ "${file}" =~ \.(${IMAGE_EXTENSIONS})$ ]]
}
export -f is_image_file

get_exif_year() {
    local file="$1"
    exiftool -CreateDate -d '%Y' "$file" | awk -F': ' '{print $2}'
}
export -f get_exif_year

get_exif_iso() {
    local file="$1"
    exiftool -iso "$file" | awk -F': ' '{print $2}'
}
export -f get_exif_iso