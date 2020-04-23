MONITOR_SET='
1-Notebook
2-Work
3-Home
'

nitrogen --head=0 --set-zoom-fill /home/det/x7/pictures/backgrounds/debian_9.png
nitrogen --head=1 --set-zoom-fill /home/det/x7/pictures/backgrounds/debian_9.png
choise=$(echo -n "${MONITOR_SET}" | rofi -dmenu -p "MONITORS SET")

case $choise in
  notebook)
    bash ~/.screenlayout/notebook.sh ;
  work)
    bash ~/.screenlayout/work.sh ;
  home)
    bash ~/.screenlayout/home.sh;;
  pc)
    bash ~/.screenlayout/pc.sh;;
esac
