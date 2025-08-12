#!/usr/bin/env bash
# Script to export MediaWiki pages and images to a local folder
# This script should be executed from your MediaWiki root directory

# Create content directory if it doesn't exist
CONTENT_DIR="./content/exports"
IMAGES_DIR="${CONTENT_DIR}/images"

echo -e "Starting wiki content export to ${CONTENT_DIR}"

# Create directories if they don't exist
if [ ! -d "$CONTENT_DIR" ]; then
  echo -e "Creating directory ${CONTENT_DIR}"
  mkdir -p "$CONTENT_DIR"
fi

if [ ! -d "$IMAGES_DIR" ]; then
  echo -e "Creating directory ${IMAGES_DIR}"
  mkdir -p "$IMAGES_DIR"
fi

# Export all pages with full history
echo -e "Exporting all wiki pages with full history..."
php maintenance/dumpBackup.php --full > "${CONTENT_DIR}/wiki_content.xml"

# Check if the content export was successful
if [ $? -eq 0 ]; then
  echo -e "Content export completed successfully!"
  echo -e "Wiki content exported to ${CONTENT_DIR}/wiki_content.xml"
  echo -e "File size: $(du -h ${CONTENT_DIR}/wiki_content.xml | cut -f1)"
else
  echo -e "Content export failed!"
  echo -e "Please check for errors above."
  exit 1
fi

# Export list of uploaded files
echo -e "\nExporting list of uploaded images..."
php maintenance/dumpUploads.php > "${CONTENT_DIR}/image_list.txt"

# Check if the image list export was successful
if [ $? -eq 0 ]; then
  echo -e "Image list export completed successfully!"
  
  # Copy all the listed images to the export directory
  echo -e "Copying images to ${IMAGES_DIR}..."
  
  # Read each line from the image list file
  while IFS= read -r img_path; do
    # Create destination directory structure
    dest_dir=$(dirname "${IMAGES_DIR}/${img_path}")
    mkdir -p "$dest_dir"
    
    # Copy the image file
    cp "./${img_path}" "${IMAGES_DIR}/${img_path}"
    
    # Check if copy was successful
    if [ $? -ne 0 ]; then
      echo -e "Warning: Failed to copy ${img_path}"
    fi
  done < "${CONTENT_DIR}/image_list.txt"
  
  echo -e "Images copied to ${IMAGES_DIR}"
else
  echo -e "Image list export failed!"
  echo -e "Please check for errors above."
fi

echo -e "\nExport process completed."
echo -e "To import this content to another wiki:"
echo -e "1. Import content: php maintenance/importDump.php ${CONTENT_DIR}/wiki_content.xml"
echo -e "2. Import images: php maintenance/importImages.php ${IMAGES_DIR}"