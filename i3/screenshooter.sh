#!/bin/bash
SCRN_FOLDER="$HOME/x7/pictures/screenshots"
FULLSCREEN_FILENAME="full-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 3 | head -n 1)-$(date +%M_%H-%d-%m-%Y).png"
REGION_FILENAME="region-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 3 | head -n 1)-$(date +%M_%H-%d-%m-%Y).png"
WINDOW_FILENAME="window-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 3 | head -n 1)-$(date +%M_%H-%d-%m-%Y).png"

case $@ in
  --fullscreen)
      xfce4-screenshooter --fullscreen;;
    
    --fullscreen-to-buffer)
      xfce4-screenshooter --fullscreen --clipboard;;
    
    --fullscreen-to-editor)
      maim -i $(xdotool getactivewindow) /${SCRN_FOLDER}/$FULLSCREEN_FILENAME && gimp ${SCRN_FOLDER}/${FULLSCREEN_FILENAME} && rm -rf ${SCRN_FOLDER}/${FULLSCREEN_FILENAME};;

    --window-to-buffer)
      maim -i $(xdotool getactivewindow) --format=png /dev/stdout | xclip -selection clipboard -t image/png -i;;
#      xfce4-screenshooter --window --clipboard;;

    --window-to-folder)
      maim -i $(xdotool getactivewindow) --format=png /${SCRN_FOLDER}/windows/$WINDOW_FILENAME;;

    --window-to-editor)
      maim -i $(xdotool getactivewindow) /${SCRN_FOLDER}/windows/$WINDOW_FILENAME && gimp ${SCRN_FOLDER}/windows/${WINDOW_FILENAME} && rm -rf ${SCRN_FOLDER}/windows/${WINDOW_FILENAME};;

    --region-to-buffer)
#      maim -s --format=png /dev/stdout | xclip -selection clipboard -t image/png -i;;
      maim -s | xclip -selection clipboard -t image/png;;
#      xfce4-screenshooter --region --clipboard;;

    --region-to-editor)
      maim -s --format=png ${SCRN_FOLDER}/regions/${REGION_FILENAME} && gimp ${SCRN_FOLDER}/regions/${REGION_FILENAME} && rm -rf ${SCRN_FOLDER}/regions/${REGION_FILENAME};;
#      xfce4-screenshooter --region --open gimp;;

    --region-to-buffer)
      maim -s --format=png /dev/stdout | xclip -selection clipboard -t image/png -i;;
      
    *)
      xfce4-screenshooter;;
      #echo -e " Right usage: \
      #  ";;
esac
