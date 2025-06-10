audiobooks() {
  echo "Syncing audiobook library..."
  rsync -az --delete --progress \
    -e "ssh -p 77" \
    --rsync-path="/opt/bin/rsync" \
    --exclude='@eaDir/' \
    --exclude='#recycle' \
    --exclude='#trash' \
    "$NAS_USER@$NAS_HOST:$AUDIOBOOKS_REMOTE_DIR" "$AUDIO_DIR"
}

music() {
  echo "Syncing music library..."
  rsync -az --delete --progress \
    -e "ssh -p 77" \
    --rsync-path="/opt/bin/rsync" \
    --exclude='@eaDir/' \
    --exclude='#recycle' \
    --exclude='#trash' \
    "$NAS_USER@$NAS_HOST:$MUSIC_REMOTE_DIR" "$AUDIO_DIR"
}

all() {
  music
  audiobooks
}
