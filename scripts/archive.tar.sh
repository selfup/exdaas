function createArchive() {
  cp -R dets_* ./archive \
    && tar -zcvf archive.tar.gz ./archive
}

if [ -d archive ]
then
  rm -rf archive.tar.gz && createArchive
else
  mkdir archive && createArchive
fi
