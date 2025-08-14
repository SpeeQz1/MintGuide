#!/usr/bin/env bash

# Extract repository path from GITHUB_REPO_URL
REPO_PATH=$(echo "$GITHUB_REPO_URL" | sed 's|https://github.com/|/data/github.com/|' | sed 's|\.git$||')

# Copy .env file if it exists
if [ -f "/workspace/.env" ] && [ -d "$REPO_PATH" ]; then
    cp /workspace/.env "$REPO_PATH/.env"
    echo "✓ Injected .env into $REPO_PATH"
fi