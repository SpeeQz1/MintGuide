#!/usr/bin/env bash
set -e

echo "Updating MediaWiki configuration..."

# Check if template file exists
if [ ! -f /var/www/html/LocalSettings.php.template ]; then
  echo "Error: Template configuration file not found."
  exit 1
fi

# Backup current configuration
if [ -f /var/www/html/LocalSettings.php ]; then
  cp /var/www/html/LocalSettings.php /var/www/html/LocalSettings.php.bak
  echo "Backed up current configuration to LocalSettings.php.bak"
fi

# Copy template to active configuration
cp /var/www/html/LocalSettings.php.template /var/www/html/LocalSettings.php
echo "Configuration updated from template."

# Run only the essential maintenance scripts using the recommended approach
cd /var/www/html
echo "Running essential maintenance operations..."
php maintenance/run.php update --quick

# Importing all the .wikitext files
if ls /var/www/html/wikitext_files/*.wikitext >/dev/null 2>&1; then
  echo "Importing wikitext files..."
  cd /var/www/html
  php maintenance/run.php importTextFiles --overwrite /var/www/html/wikitext_files/*.wikitext
fi

# Import images
if ls /var/www/html/resources/assets/images/* >/dev/null 2>&1; then
  echo "Importing images..."
  cd /var/www/html
  php maintenance/run.php importImages --overwrite /var/www/html/resources/assets/images
fi

# Restart Apache (works for the official MediaWiki Docker image)
echo "Restarting Apache to apply changes..."
apachectl graceful

echo "Configuration update complete. Changes are now active."
echo "If changes are not visible, you may need to restart the container:"
echo "docker-compose restart mediawiki"