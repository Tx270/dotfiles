audiobooks() {
  echo "Syncing added audiobooks..."
  rsync -az --progress --ignore-existing --update \
    -e "ssh -p 77" \
    --rsync-path="/opt/bin/rsync" \
    --exclude='@eaDir/' \
    --exclude='#recycle' \
    --exclude='#trash' \
    "$AUDIO_DIR/Audiobooks/" "$NAS_USER@$NAS_HOST:$AUDIOBOOKS_REMOTE_DIR"
}

music() {
  echo "Syncing added songs..."
  rsync -az --progress --ignore-existing --update \
    -e "ssh -p 77" \
    --rsync-path="/opt/bin/rsync" \
    --exclude='@eaDir/' \
    --exclude='#recycle' \
    --exclude='#trash' \
    "$AUDIO_DIR/Music/" "$NAS_USER@$NAS_HOST:$MUSIC_REMOTE_DIR"
}
all() {
  music
  audiobooks
}
