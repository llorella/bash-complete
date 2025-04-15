#!/bin/bash

# llt_bash_completion.sh - Bash integration for LLT command autocomplete
# Add to ~/.bashrc by running: echo "source $(realpath llt_bash_completion.sh)" >> ~/.bashrc

# Function to transform natural language into bash commands with a preview
function llm_complete_with_preview() {
    local current_line="${READLINE_LINE}"
    
    # Skip if the line is empty
    if [ -z "$current_line" ]; then
        return
    fi
    
    # Save cursor position and prepare preview area
    tput sc
    tput cud1
    tput el
    
    echo -n "Generating command..."
    
    # Get command suggestion from helper script
    local bash_command=$("$HOME/bin/llt_shell_helper.sh" "$current_line")
    local exit_code=$?
    
    # Check if command generation was successful
    if [ $exit_code -ne 0 ]; then
        tput el
        echo -e "\033[31mError generating command\033[0m"
        sleep 1
        tput cuu1
        tput el
        tput rc
        return
    fi
    
    # Show preview
    tput el
    echo -e "\033[36m$bash_command\033[0m"
    echo -n "Use this command? [Y/n] "
    read -n 1 confirm
    
    # Clean up preview area
    tput cuu1
    tput el
    tput cuu1
    tput el
    tput rc
    
    # Apply command if confirmed
    if [[ "$confirm" != "n" && "$confirm" != "N" ]]; then
        READLINE_LINE="$bash_command"
        READLINE_POINT=${#bash_command}
    fi
}

# Function to clean older cache files (> 30 days)
function clean_llt_cache() {
    find "$HOME/.llt_bash_cache" -type f -mtime +30 -delete
    find "$HOME/.llt_bash_cache" -type f -size +1M -delete
}

# Clean cache periodically (once every 10 invocations)
if [ ! -f "$HOME/.llt_bash_cache/.last_clean" ] || 
   [ $(( $(cat "$HOME/.llt_bash_cache/.last_clean" 2>/dev/null || echo 0) + 1 )) -ge 10 ]; then
    clean_llt_cache
    echo "0" > "$HOME/.llt_bash_cache/.last_clean"
else
    count=$(( $(cat "$HOME/.llt_bash_cache/.last_clean" 2>/dev/null || echo 0) + 1 ))
    echo "$count" > "$HOME/.llt_bash_cache/.last_clean"
fi

# Create required directories
mkdir -p "$HOME/bin"
mkdir -p "$HOME/.llt_bash_cache"
chmod 700 "$HOME/.llt_bash_cache"

# If helper script doesn't exist, show instructions
if [ ! -f "$HOME/bin/llt_shell_helper.sh" ]; then
    echo "llt_shell_helper.sh not found in ~/bin/"
    echo "Please copy the script to that location and make it executable:"
    echo "cp llt_shell_helper.sh ~/bin/"
    echo "chmod +x ~/bin/llt_shell_helper.sh"
fi

# Key binding for the completion function
bind -x '"\C-x\C-l": llm_complete_with_preview'

echo "LLT Bash Autocomplete loaded. Use Ctrl+X followed by Ctrl+L to get suggestions." 