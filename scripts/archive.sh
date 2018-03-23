function createArchive() {
  cp -R dets_* ./archive \
    && tar -zcvf archive.tar.gz ./archive
}

if [ -d archive ]
then
  createArchive
else
  mkdir archive && createArchive
fi
