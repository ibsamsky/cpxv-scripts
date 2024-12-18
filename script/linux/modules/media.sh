#!/usr/bin/env bash

# delete media files

media() {
  exts=(
    mp3 mov mp4 avi mpg \
    mpeg flac m4a flv ogg \
    gif png jpg jpeg wma \
    wmv mkv webp aiff alac \
    tiff aac webm wav opus \
    heif avif jxl bmp jfif
  )

  filename="foundmedia.$(date '+%Y%m%d-%H%M%S')"
  filepath="${BASEDIR}/tmp/${filename}"

  for ext in "${exts[@]}"; do
    find /home -not -path "/home/*/snap/*" -iname "*.${ext}" -type f 2>/dev/null | tee -a "${filepath}"
  done

  if [[ -z $(cat "${filepath}") ]]; then echo "No media files found!"; return; fi

  if prompt "Delete these files now?" "y"; then
    while read -r line; do rm -f "${line}"; done < "${filepath}"
  else
    mv -f "${filepath}" "${BASEDIR}/out/"
    echo "Files can be found at ${BASEDIR}/out/${filename} for deletion"
  fi
}