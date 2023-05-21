#!/usr/bin/env sh

if [ "$radarr_eventtype" == "Download" ]; then
  curl -sSX POST http://qbittorrent.lan:2468/api/webhook \
    --data-urlencode "path=$radarr_moviefile_path"
fi
