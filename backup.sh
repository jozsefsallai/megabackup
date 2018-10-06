FORMATTED_DATE=$(date "+%y%m%d_%H%M")
ZIP_NAME_WITH_DATETIME="backup_$FORMATTED_DATE.zip"
BACKUP_PATHS=$(cat paths.txt)

MYSQL_DEFAULTS_EXTRA_FILE="/etc/mysql/debian.cnf"  # change this if you have to

MEGA_FREE_SPACE=$(megadf --free)

gracefully_exit() {
  echo "error: $1"
  exit $2
}

warning() {
  echo "warning: $1"
}

echo "Preparing..."

mkdir -p db files

echo "Collecting files..."

while read -r LINE; do
  if [ ! -f "$LINE" ] && [ ! -d "$LINE" ]; then
    warning "File or directory doesn't exist: $LINE"
    continue
  fi
  cp -r --parents "$LINE" "files"
done <<< "$BACKUP_PATHS"

echo "Creating MySQL dumps..."

sudo mysqldump --defaults-extra-file=$MYSQL_DEFAULTS_EXTRA_FILE --all-databases > "db/backup_${FORMATTED_DATE}.sql"

echo "Zipping..."

zip -rq "$ZIP_NAME_WITH_DATETIME" db files

if [ ! -f "$ZIP_NAME_WITH_DATETIME" ]; then
  gracefully_exit "Failed to create the archive. Exiting." 1
fi

echo "Calculating archive size..."

ARCHIVE_SIZE=$(stat --printf="%s" $ZIP_NAME_WITH_DATETIME)

echo "Freeing up space on MEGA..."

while [ "$MEGA_FREE_SPACE" -lt "$ARCHIVE_SIZE" ]; do
  RFILE_TO_DELETE=$(megals -n /Root | sed -n 1p)
  megarm "/Root/$RFILE_TO_DELETE"
  MEGA_FREE_SPACE=$(megadf --free)
  echo " * Removed $RFILE_TO_DELETE"
done

echo "Enough space for the new archive, uploading..."

megaput "$ZIP_NAME_WITH_DATETIME"

echo "Cleaning up..."

rm -rf db files "$ZIP_NAME_WITH_DATETIME"

echo "Done."

exit 0
