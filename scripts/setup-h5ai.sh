#!/usr/bin/env bash
set -e

echo "Setting up h5ai for MediaWiki images..."

# Enable Apache modules needed for h5ai
a2enmod rewrite
a2enmod dir

# Create h5ai Apache configuration
cat > /etc/apache2/conf-available/h5ai.conf << 'EOF'
# h5ai configuration for MediaWiki images
<Directory "/var/www/html/images">
    # Enable h5ai directory listing
    DirectoryIndex index.html index.php /_h5ai/public/index.php
    
    # Allow .htaccess files
    AllowOverride All
    
    # Enable directory browsing
    Options +Indexes +FollowSymLinks
    
    # Allow access
    Require all granted
</Directory>

# Also enable h5ai for the root if someone accesses it directly
<Directory "/var/www/html">
    DirectoryIndex index.php index.html /_h5ai/public/index.php
</Directory>

# Set up alias for h5ai files
Alias /_h5ai /var/www/html/_h5ai
<Directory "/var/www/html/_h5ai">
    AllowOverride All
    Options +Indexes +FollowSymLinks
    Require all granted
</Directory>
EOF

# Enable the h5ai configuration
a2enconf h5ai

# Set proper permissions for h5ai
chown -R www-data:www-data /var/www/html/_h5ai
chmod -R 755 /var/www/html/_h5ai

# Create a simple .htaccess in images directory for h5ai
cat > /var/www/html/images/.htaccess << 'EOF'
# Enable h5ai for this directory
DirectoryIndex /_h5ai/public/index.php

# Optional: Disable direct access to some file types for security
<Files "*.php">
    Require all denied
</Files>

# But allow h5ai to work
<Files "index.php">
    Require all granted
</Files>
EOF

echo "h5ai setup completed!"