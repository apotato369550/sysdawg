#!/usr/bin/env bash

# setup-ssh.sh - Configure passwordless SSH from orion to apollo
# This script generates SSH keys (if needed) and copies them to apollo

set -e  # Exit on error

# Color output for readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}SSH Setup for sysdawg${NC}"
echo -e "${BLUE}========================================${NC}"
echo

# Step 1: Check if .env exists
if [ ! -f .env ]; then
  echo -e "${YELLOW}⚠ .env file not found${NC}"
  echo "Create .env from .env.example first:"
  echo "  cp .env.example .env"
  echo "  # Edit .env with apollo credentials"
  exit 1
fi

# Load .env variables
set +e  # Temporarily disable exit on error for sourcing
source .env
set -e

# Validate required variables
if [ -z "$APOLLO_HOST" ] || [ -z "$APOLLO_USER" ]; then
  echo -e "${RED}✗ APOLLO_HOST and APOLLO_USER must be set in .env${NC}"
  exit 1
fi

echo -e "${BLUE}Using .env configuration:${NC}"
echo "  Host: $APOLLO_HOST"
echo "  User: $APOLLO_USER"
echo "  Port: ${APOLLO_PORT:-22}"
echo

# Step 2: Check if SSH key exists
SSH_KEY_PATH="${HOME}/.ssh/id_rsa"

if [ ! -f "$SSH_KEY_PATH" ]; then
  echo -e "${YELLOW}⚠ No SSH key found at $SSH_KEY_PATH${NC}"
  echo -e "${BLUE}Generating new SSH key...${NC}"
  ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -C "orion-sysdawg"
  echo -e "${GREEN}✓ SSH key generated${NC}"
  echo
else
  echo -e "${GREEN}✓ SSH key already exists at $SSH_KEY_PATH${NC}"
  echo
fi

# Step 3: Copy SSH key to apollo
echo -e "${BLUE}Copying public key to apollo...${NC}"
echo "You may be prompted for the password for $APOLLO_USER@$APOLLO_HOST"
echo

SSH_PORT="${APOLLO_PORT:-22}"

if ssh-copy-id -i "$SSH_KEY_PATH.pub" -p "$SSH_PORT" "$APOLLO_USER@$APOLLO_HOST" 2>/dev/null; then
  echo -e "${GREEN}✓ Public key copied to apollo${NC}"
  echo
else
  echo -e "${RED}✗ Failed to copy public key${NC}"
  echo "Troubleshooting:"
  echo "  1. Check that apollo is reachable: ping $APOLLO_HOST"
  echo "  2. Check SSH credentials in .env"
  echo "  3. Manually copy with: ssh-copy-id -i $SSH_KEY_PATH.pub -p $SSH_PORT $APOLLO_USER@$APOLLO_HOST"
  exit 1
fi

# Step 4: Test SSH connection
echo -e "${BLUE}Testing passwordless SSH connection...${NC}"

if ssh -p "$SSH_PORT" "$APOLLO_USER@$APOLLO_HOST" "echo 'SSH connection successful'" >/dev/null 2>&1; then
  echo -e "${GREEN}✓ Passwordless SSH connection verified${NC}"
  echo
else
  echo -e "${RED}✗ SSH connection failed${NC}"
  echo "Troubleshooting:"
  echo "  1. Check the key was copied: ssh -p $SSH_PORT $APOLLO_USER@$APOLLO_HOST 'ls -la ~/.ssh/authorized_keys'"
  echo "  2. Check SSH service is running on apollo"
  echo "  3. Check firewall rules"
  exit 1
fi

# Step 5: Verify ollama is available on apollo
echo -e "${BLUE}Checking if ollama is available on apollo...${NC}"

if ssh -p "$SSH_PORT" "$APOLLO_USER@$APOLLO_HOST" "which ollama" >/dev/null 2>&1; then
  echo -e "${GREEN}✓ ollama found on apollo${NC}"
  echo
else
  echo -e "${YELLOW}⚠ ollama not found on apollo${NC}"
  echo "Install ollama on apollo:"
  echo "  ssh $APOLLO_USER@$APOLLO_HOST"
  echo "  # Follow: https://ollama.ai/download"
  echo
fi

# Step 6: Summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ SSH setup complete${NC}"
echo -e "${GREEN}========================================${NC}"
echo
echo "You can now use sysdawg:"
echo "  ./sysdawg 'your question here'"
echo
