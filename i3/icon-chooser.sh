#!/bin/bash
#
# TODO: Сделать нумерованый список иконок и принимать как аргумент только иконку.
#
ICONS_LIST="\n\n \n \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
PRESET_LIST="
MTL
SS
App
Book
CFG
EDIT
I4S
RYS
SSH
X7
"

NAMES_LIST="
ANSIBLE
Deploy
EDIT
Firefox
I3
MSGR
DEV
STAGE
PROD
Polybar
Terminal
Typhora
"

icon=$(echo -e "${ICONS_LIST}" | rofi -dmenu -p "SET ICON")
prefix="$(echo -e "${PRESET_LIST}" | rofi -dmenu -p "SET PREFIX")"
if [[ ! -z "$prefix" ]]; then
  label="$icon $prefix | $(echo -e "${NAMES_LIST}" | rofi -dmenu -p "SET NAME")"
else
  label="$icon $prefix $(echo -e "${NAMES_LIST}" | rofi -dmenu -p "SET NAME")"

fi

echo "$label"
