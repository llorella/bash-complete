#!/bin/bash

# LLT Bash Autocomplete System Installer
# This script installs the LLT bash autocomplete system

set -e

# Colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== LLT Bash Autocomplete System Installer ===${NC}"
echo

# Check if LLT is installed
if ! command -v llt &> /dev/null; then
    echo -e "${RED}Error: LLT is not installed or not in PATH${NC}"
    echo "Please install LLT first."
    exit 1
fi

# Create required directories
echo -e "${BLUE}Creating required directories...${NC}"
mkdir -p "$HOME/bin"
mkdir -p "$HOME/.llt_bash_cache"
chmod 700 "$HOME/.llt_bash_cache"
echo -e "${GREEN}Done${NC}"

# Copy scripts to their destinations
echo -e "${BLUE}Installing scripts...${NC}"
cp "$(dirname "$0")/llt_shell_helper.sh" "$HOME/bin/"
chmod +x "$HOME/bin/llt_shell_helper.sh"
echo -e "${GREEN}Installed llt_shell_helper.sh${NC}"

cp "$(dirname "$0")/llt_bash_completion.sh" "$HOME/"
chmod +x "$HOME/llt_bash_completion.sh"
echo -e "${GREEN}Installed llt_bash_completion.sh${NC}"

# Add to .bashrc if not already there
echo -e "${BLUE}Configuring bash integration...${NC}"
COMPLETION_PATH="$HOME/llt_bash_completion.sh"
BASHRC_LINE="source \"$COMPLETION_PATH\""

if grep -q "$BASHRC_LINE" "$HOME/.bashrc"; then
    echo -e "${GREEN}Bash integration already configured${NC}"
else
    echo >> "$HOME/.bashrc"
    echo "# LLT Bash Autocomplete" >> "$HOME/.bashrc"
    echo "$BASHRC_LINE" >> "$HOME/.bashrc"
    echo -e "${GREEN}Added bash integration to ~/.bashrc${NC}"
fi

echo
echo -e "${GREEN}Installation complete!${NC}"
echo -e "To start using LLT Bash Autocomplete, either:"
echo -e "  - Run ${BLUE}source ~/.bashrc${NC}"
echo -e "  - Or restart your terminal"
echo
echo -e "Then type a natural language description and press ${BLUE}Ctrl+X followed by Ctrl+L${NC}"
echo -e "Example: 'find all python files modified in the last week' ${BLUE}[Ctrl+X Ctrl+L]${NC}" 