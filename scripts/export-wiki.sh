#!/usr/bin/env bash
# Script to export MediaWiki pages and their history to a local folder
# This script should be executed from your MediaWiki root directory

# Create content directory if it doesn't exist
CONTENT_DIR="./content/exports"

echo -e "Starting wiki content export to ${CONTENT_DIR}"

# Create the directory if it doesn't exist
if [ ! -d "$CONTENT_DIR" ]; then
  echo -e "Creating directory ${CONTENT_DIR}"
  mkdir -p "$CONTENT_DIR"
fi

# Export all pages with full history
echo -e "Exporting all wiki pages with full history..."
php maintenance/dumpBackup.php --full > "${CONTENT_DIR}/wiki_content.xml"

# Check if the export was successful
if [ $? -eq 0 ]; then
  echo -e "Export completed successfully!"
  echo -e "Wiki content exported to ${CONTENT_DIR}/wiki_content.xml"
  echo -e "File size: $(du -h ${CONTENT_DIR}/wiki_content.xml | cut -f1)"
else
  echo -e "Export failed!"
  echo -e "Please check for errors above."
fi

echo -e "\nExport process completed."