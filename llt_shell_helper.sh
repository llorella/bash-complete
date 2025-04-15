#!/bin/bash

# Set up logging
LOG_FILE="/tmp/llt_shell_helper.log"
function log_message() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_message "Script started with arguments: $*"

DESCRIPTION="$*"
CACHE_DIR="$HOME/.llt_bash_cache"
log_message "Using cache directory: $CACHE_DIR"

mkdir -p "$CACHE_DIR"
chmod 700 "$CACHE_DIR"
log_message "Cache directory created/verified with permissions 700"

# Create a cache key from the description
CACHE_KEY=$(echo "$DESCRIPTION" | md5sum | cut -d' ' -f1)
CACHE_FILE="$CACHE_DIR/$CACHE_KEY"
log_message "Cache key: $CACHE_KEY, Cache file: $CACHE_FILE"

# Check if we have a cached result
if [ -f "$CACHE_FILE" ]; then
  log_message "Cache hit! Using cached result"
  cat "$CACHE_FILE"
  log_message "Exiting with cached result"
  exit 0
else
  log_message "Cache miss. Generating new command"
fi

# Context template for LLT
log_message "Building context template"
CONTEXT=$(cat <<EOF
Convert this natural language request into a single bash command:
"$DESCRIPTION"

Current directory: $(pwd)
Recent commands:
$(history | tail -5 2>/dev/null || echo "No history available")
Directory contents:
$(ls -la | head -10)

Return the bash command inside a <bash_command> tag. You can use the space outside of the tag to add your thought process.
EOF
)

# quit

# LLT command template
log_message "Calling sonnet to generate command"
RESPONSE=$(sonnet --non_interactive \
  --temperature 0.3 \
  --prompt "$CONTEXT" \
  --xml_wrap "instruction" \
  --prompt "Here is the bash command for the task in <bash_command> tags:" \
  --change_role assistant \
  --complete)

# Extract the command from the response
log_message "Extracting command from response"
COMMAND=$(echo "$RESPONSE" | grep -oP '(?<=<bash_command>).*(?=</bash_command>)' || echo "")

if [ -z "$COMMAND" ]; then
  log_message "Failed to extract command from response"
  echo "Error: Could not generate a valid command" >&2
  exit 1
fi

# Cache the result
log_message "Caching result to $CACHE_FILE"
echo "$COMMAND" > "$CACHE_FILE"

# Output the command
log_message "Returning command: $COMMAND"
echo "$COMMAND"
