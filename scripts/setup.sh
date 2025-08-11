#!/usr/bin/env bash
set -e

# Function to wait for MySQL to be ready
wait_for_mysql() {
  echo "Waiting for MySQL to be ready..."
  max_attempts=60
  counter=0
  
  while [ $counter -lt $max_attempts ]; do
    if mysqladmin ping -h "$MEDIAWIKI_DB_HOST" -u "$MEDIAWIKI_DB_USER" -p"$MEDIAWIKI_DB_PASSWORD" --silent; then
      echo "MySQL is ready!"
      return 0
    fi
    echo -n "."
    sleep 1
    counter=$((counter+1))
  done
  
  echo "Error: MySQL did not become ready in time."
  return 1
}

# Check if database tables exist
check_tables() {
  tables=$(mysql -h "$MEDIAWIKI_DB_HOST" -u "$MEDIAWIKI_DB_USER" -p"$MEDIAWIKI_DB_PASSWORD" "$MEDIAWIKI_DB_NAME" -e "SHOW TABLES LIKE 'user'" 2>/dev/null | wc -l)
  if [ "$tables" -gt 1 ]; then
    return 0
  else
    return 1
  fi
}

# Wait for MySQL to be ready
wait_for_mysql

# Check if LocalSettings.php exists in the container
if [ -f /var/www/html/LocalSettings.php ]; then
  echo "LocalSettings.php already exists, checking database tables..."
  
  if check_tables; then
    echo "Database tables already exist, starting web server..."
  else
    echo "Database tables don't exist, running maintenance/update.php..."
    cd /var/www/html
    php maintenance/update.php --quick
  fi
else
  echo "No LocalSettings.php found, running installation process..."
  
  # Run the installation script
  cd /var/www/html
  php maintenance/install.php \
    --dbname="$MEDIAWIKI_DB_NAME" \
    --dbserver="$MEDIAWIKI_DB_HOST" \
    --dbuser="$MEDIAWIKI_DB_USER" \
    --dbpass="$MEDIAWIKI_DB_PASSWORD" \
    --server="$MEDIAWIKI_SERVER" \
    --scriptpath="" \
    --pass="$MEDIAWIKI_ADMIN_PASS" \
    "$MEDIAWIKI_SITENAME" \
    "$MEDIAWIKI_ADMIN_USER"
  
  # Once installation is complete, replace the generated LocalSettings.php with our template
  if [ -f /var/www/html/LocalSettings.php.template ]; then
    echo "Using template configuration file..."
    cp /var/www/html/LocalSettings.php.template /var/www/html/LocalSettings.php
    
    # Run update.php to ensure all extensions are properly installed
    php maintenance/update.php --quick
  else
    echo "Warning: Template configuration file not found. Using generated configuration."
  fi

  # Add this to your setup.sh after the MediaWiki installation
  if ls /var/www/html/wikitext_files/*.wikitext >/dev/null 2>&1; then
    echo "Importing wikitext files..."
    cd /var/www/html
    php maintenance/run.php importTextFiles /var/www/html/wikitext_files/*.wikitext
  fi
fi

# Start Apache
echo "Starting Apache..."
apache2-foreground