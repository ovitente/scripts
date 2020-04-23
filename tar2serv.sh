DIR_LIST="audio docs programs pictures dist projects"
for i in $DIR_LIST; do
  echo "Proceeding [$i]"
  tar zcf - ~/x7/$i | ssh det@unisync "cat > /media/x7/$i.tar.gz"
done
