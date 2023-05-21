#!/bin/bash
 
torrentclientname="qBittorrent"
usenetclientname="SABnzbd"
xseed_host="cross-seed"
xseed_port="2468"
 
# Determine app and set variables
if [ -n "$radarr_eventtype" ]; then
    app="radarr"
    clientID=${radarr_download_client}
    downloadID=${radarr_download_id}
    filePath=${radarr_moviefile_path}
    eventType=${radarr_eventtype}
elif [ -n "$sonarr_eventtype" ]; then
    app="sonarr"
    clientID=${sonarr_download_client}
    downloadID=${sonarr_download_id}
    filePath=${sonarr_series_path}
    eventType=${sonarr_eventtype}
elif [ -n "$Lidarr_EventType" ]; then
    app="lidarr"
    clientID=${lidarr_Download_Client}
    filePath=${lidarr_Artist_Path}
    downloadID=${lidarr_Download_Id}
    eventType=${lidarr_EventType}
else
    echo "Unknown Event Type. Failing."
    exit 1
fi
echo "$app detected with event type $eventType"
 
# Handle Test Event
if [ "$eventType" == "Test" ]; then
    echo "Test passed for $app. DownloadClient: $clientID, DownloadId: $downloadID and FilePath: $filePath"
    exit 0
fi
# Ensure we have a downloadID
if [ -z "$downloadID" ]; then
    echo "DownloadID is empty from $app. Skipping cross-seed search. DownloadClient: $clientID and DownloadId: $downloadID"
    exit 0
fi
# Ensure we have a filePath
if [ -z "$filePath" ]; then
    echo "FilePath is empty from $app. Skipping cross-seed search. DownloadClient: $clientID and FilePath: $filePath"
    exit 0
fi
# Ensure we have a clientID, whether it is a torrent or usenet client, and that it is what the user configured. If it is, search.
if [ "$clientID" == "$torrentclientname" ]; then
    echo "Client $torrentclientname trigged search for DownloadId $downloadID"
    xseed_resp=$(curl --silent --output /dev/null --write-out "%{http_code}" -XPOST http://"$xseed_host":"$xseed_port"/api/webhook --data-urlencode infoHash="$downloadID")
    echo ""
elif [ "$clientID" == "$usenetclientname" ]; then
    echo "Client $usenetclientname trigged search for FilePath $filePath"
    xseed_resp=$(curl --silent --output /dev/null --write-out "%{http_code}" -XPOST http://"$xseed_host":"$xseed_port"/api/webhook --data-urlencode path="$filePath")
    echo ""
else
    echo "Client $clientID does not match configured Client of $torrentclientname or $usenetclientname. Skipping..."
    exit 0
fi
# Handle Cross Seed Response
if [ "$xseed_resp" == "204" ]; then # 204 = Success per Xseed docs
    echo "Success. cross-seed search triggered by $app for DownloadClient: $clientID, DownloadId: $downloadID and FilePath: $filePath"
    exit 0
else
    echo "cross-seed webhook failed - HTTP Code $xseed_resp from $app for DownloadClient: $clientID, DownloadId: $downloadID and FilePath: $filePath"
    exit 1
fi
