#!/usr/bin/env bash
# Script to generate secure random keys for MediaWiki

# Change to script directory and print working directory
cd "$(dirname "$0")/.." && echo "Working directory: $(pwd)"

# ANSI escape codes
RESET="\e[0m"
BOLD="\e[1m"

GREEN="\e[32m"
CYAN="\e[36m"
RED="\e[31m"

# Generate a new secret key (64 character hex string = 256 bits of entropy)
SECRET_KEY=$(openssl rand -hex 32)

# Generate a new upgrade key (16 character hex string = 64 bits of entropy)
UPGRADE_KEY=$(openssl rand -hex 8)

echo "Generated new MediaWiki security keys:"
echo ""
echo -e "MEDIAWIKI_SECRET_KEY=$GREEN$BOLD$SECRET_KEY$RESET"
echo -e "MEDIAWIKI_UPGRADE_KEY=$GREEN$BOLD$UPGRADE_KEY$RESET"
echo -e "$CYAN"
echo "Add these to your .env file or export them as environment variables"
echo "before running docker-compose up."
echo -e "$RESET"

# Optionally update the .env file directly
if [ -f .env ]; then

  MSG="Do you want to update your existing .env file with these keys? (y/N): "
  read -p "$(echo -e "${RED}${MSG}${RESET}")" -n 1 -r
  echo ""

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Create backup of original .env file
    cp .env .env.backup

    # Update the keys in the .env file
    sed -i "s/^MEDIAWIKI_SECRET_KEY=.*/MEDIAWIKI_SECRET_KEY=$SECRET_KEY/" .env
    sed -i "s/^MEDIAWIKI_UPGRADE_KEY=.*/MEDIAWIKI_UPGRADE_KEY=$UPGRADE_KEY/" .env

    echo "Updated .env file. Original saved as .env.backup"
  fi
fi