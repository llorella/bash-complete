#!/bin/bash

# llt_bash_completion.sh - Bash integration for LLT command autocomplete
# Add to ~/.bashrc by running: echo "source $(realpath llt_bash_completion.sh)" >> ~/.bashrc

# Function to transform natural language into bash commands without preview/confirmation
function llm_complete_with_preview() {
    local current_line="${READLINE_LINE}"
    
    # Skip if the line is empty
    if [ -z "$current_line" ]; then
        return
    fi
    
    # Get command suggestion from helper script
    # Use stdbuf to avoid buffering issues that might hide errors
    local bash_command=$(stdbuf -o0 "$HOME/bin/llt_shell_helper.sh" "$current_line" 2>&1)
    local exit_code=$?
    
    # Check if command generation was successful
    if [ $exit_code -ne 0 ]; then
        # Temporarily display error below the prompt
        tput sc     # Save cursor position
        tput cud1   # Move cursor down one line
        tput el     # Clear the line
        echo -e "\033[31mError: $bash_command\033[0m" # Display error in red
        sleep 2     # Show error for 2 seconds
        tput el     # Clear the error line
        tput rc     # Restore cursor position
        return
    fi
    
    # Directly replace the line content with the generated command
    READLINE_LINE="$bash_command"
    READLINE_POINT=${#bash_command}
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
# Note: The function name is kept for simplicity, even though preview is removed
bind -x '"\C-x\C-l": llm_complete_with_preview'

# Removed the echo message on load to make it quieter
# echo "LLT Bash Autocomplete loaded. Use Ctrl+X followed by Ctrl+L to get suggestions." 