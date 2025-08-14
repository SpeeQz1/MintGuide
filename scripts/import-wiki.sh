#!/usr/bin/env bash

# Simple script to import files from the imports folder

IMPORTS_DIR="./content/imports"

# Check if imports directory exists
if [ ! -d "$IMPORTS_DIR" ]; then
  echo "Imports directory not found: $IMPORTS_DIR"
  exit 1
fi

# Import XML dumps
if ls "$IMPORTS_DIR"/*.xml >/dev/null 2>&1; then
  echo "Importing XML dumps..."
  for xml_file in "$IMPORTS_DIR"/*.xml; do
    filename=$(basename "$xml_file")
    echo "Importing $filename"
    su -s /bin/bash www-data -c "php maintenance/run.php importDump \"/var/www/html/content/imports/$filename\""
  done
fi

# Import wikitext files
if ls "$IMPORTS_DIR"/*.wikitext >/dev/null 2>&1; then
  echo "Importing wikitext files..."
  su -s /bin/bash www-data -c "php maintenance/run.php importTextFiles --overwrite \"/var/www/html/content/imports/*.wikitext\""
fi

# Import images from images subfolder
if [ -d "$IMPORTS_DIR/images" ] && ls "$IMPORTS_DIR/images"/* >/dev/null 2>&1; then
  echo "Importing images..."
  
  # Check if there's a nested images directory structure
  if [ -d "$IMPORTS_DIR/images/images" ]; then
    echo "Found nested images directory, adjusting path..."
    su -s /bin/bash www-data -c "php maintenance/run.php importImages --overwrite --search-recursively \"/var/www/html/content/imports/images/images\""
  else
    echo "Using standard images directory..."
    su -s /bin/bash www-data -c "php maintenance/run.php importImages --overwrite --search-recursively \"/var/www/html/content/imports/images\""
  fi
fi

echo "Import process completed."