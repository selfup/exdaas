if [ -d archive.zip ]
then
  rm -rf archive.zip && zip archive dets_*
else
  zip archive dets_*
fi
