#!/bin/sh

## Use the following to upload to backblaze
zip -r south-america_falkland_islands.zip south-america_falkland_islands.mbtiles
FILENAME=south-america_falkland_islands.mbtiles
FILESIZE=$(stat -c%s "$FILENAME")
b2 upload-file --info file-size=$FILESIZE cachly-offline-maps3 south-america_falkland_islands.zip south-america_falkland_islands.zip

## After uploading json files on maps1.cachly.com need to be updated as well as the json.sh script run.