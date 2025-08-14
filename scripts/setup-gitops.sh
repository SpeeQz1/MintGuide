#!/usr/bin/env bash
# Script to set up GitOps with doco-cd for Mint Wiki

set -e

# ANSI colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Mint Wiki GitOps Setup with doco-cd${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Generate webhook secret
echo -e "${YELLOW}Generating webhook secret...${NC}"
WEBHOOK_SECRET=$(openssl rand -hex 32)
echo -e "${GREEN}Generated webhook secret: ${WEBHOOK_SECRET}${NC}"
echo ""

# Update .env file
if [ -f .env ]; then
    echo -e "${YELLOW}Updating existing .env file...${NC}"
    # Check if WEBHOOK_SECRET already exists
    if grep -q "WEBHOOK_SECRET=" .env; then
        sed -i "s/^WEBHOOK_SECRET=.*/WEBHOOK_SECRET=${WEBHOOK_SECRET}/" .env
    else
        echo "WEBHOOK_SECRET=${WEBHOOK_SECRET}" >> .env
    fi
else
    echo -e "${YELLOW}Creating .env file from template...${NC}"
    cp .env.example .env
    sed -i "s/your-webhook-secret-here/${WEBHOOK_SECRET}/" .env
fi

echo -e "${GREEN}✓ Environment file updated${NC}"
echo ""

# Update deployments.yaml with repository info
echo -e "${YELLOW}Please provide your GitHub repository information:${NC}"
read -p "GitHub username: " GITHUB_USER
read -p "Repository name: " REPO_NAME
read -p "Branch name (default: main): " BRANCH_NAME
BRANCH_NAME=${BRANCH_NAME:-main}

echo ""
echo -e "${YELLOW}GitHub Personal Access Token required for repository access:${NC}"
echo -e "${CYAN}Create one at: https://github.com/settings/tokens${NC}"
echo -e "${CYAN}Required permissions: 'repo' (for private repos) or 'public_repo' (for public repos)${NC}"
read -p "GitHub Personal Access Token: " GIT_ACCESS_TOKEN

GITHUB_REPO_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

# Update .env file with repository information
if grep -q "GITHUB_REPO_URL=" .env; then
    sed -i "s|^GITHUB_REPO_URL=.*|GITHUB_REPO_URL=${GITHUB_REPO_URL}|" .env
else
    echo "GITHUB_REPO_URL=${GITHUB_REPO_URL}" >> .env
fi

if grep -q "GITHUB_BRANCH=" .env; then
    sed -i "s/^GITHUB_BRANCH=.*/GITHUB_BRANCH=${BRANCH_NAME}/" .env
else
    echo "GITHUB_BRANCH=${BRANCH_NAME}" >> .env
fi

if grep -q "GIT_ACCESS_TOKEN=" .env; then
    sed -i "s/^GIT_ACCESS_TOKEN=.*/GIT_ACCESS_TOKEN=${GIT_ACCESS_TOKEN}/" .env
else
    echo "GIT_ACCESS_TOKEN=${GIT_ACCESS_TOKEN}" >> .env
fi

echo -e "${GREEN}✓ Deployment configuration updated${NC}"
echo ""

# Get server IP for webhook URL
SERVER_IP=$(curl -s ifconfig.me || echo "YOUR_SERVER_IP")

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}           Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo ""
echo -e "${YELLOW}1. Start the services:${NC}"
echo "   docker compose up -d"
echo ""
echo -e "${YELLOW}2. Configure GitHub webhook:${NC}"
echo "   • Go to: https://github.com/${GITHUB_USER}/${REPO_NAME}/settings/hooks"
echo "   • Click 'Add webhook'"
echo "   • Payload URL: http://${SERVER_IP}:8080/webhook"
echo "   • Content type: application/json"
echo "   • Secret: ${WEBHOOK_SECRET}"
echo "   • Events: Just the push event"
echo "   • Active: ✓"
echo ""
echo -e "${YELLOW}3. Test the webhook:${NC}"
echo "   • Make a commit to your repository"
echo "   • Check logs: docker logs doco-cd"
echo ""
echo -e "${GREEN}Your GitOps workflow is ready!${NC}"