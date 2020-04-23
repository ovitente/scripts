#!/bin/sh
# Scan directory for changes and apply command to item
DIR_NAME="$1"
inotifywait -m -r -e create,access --format '%w%f' "${DIR_NAME}" | while read ITEM
do
  chown x7:x7 ${ITEM}
  chmod u=rwX,g=rwX,o= ${ITEM}
done
