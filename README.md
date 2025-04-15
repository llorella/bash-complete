# LLT Bash Autocomplete System

A natural language to bash command autocomplete system that uses LLT (Little Language Terminal) to transform natural language descriptions into executable bash commands. The system binds to keyboard shortcuts in bash and provides real-time command suggestions.

## Features

- Transform natural language descriptions into bash commands
- Keyboard shortcut integration with GNU Readline
- Command preview and confirmation system
- Caching for faster repeated suggestions
- Automatic cache maintenance
- Security hardened implementation

## Requirements

- LLT (Little Language Terminal)
- GNU Readline
- Bash 4.0+
- Basic Unix utilities: sed, grep, md5sum

## Installation

### Automatic Installation

Run the installer script:

```bash
chmod +x install_llt_autocomplete.sh
./install_llt_autocomplete.sh
```

### Manual Installation

1. Create the required directories:

```bash
mkdir -p ~/bin
mkdir -p ~/.llt_bash_cache
chmod 700 ~/.llt_bash_cache
```

2. Copy the helper script and make it executable:

```bash
cp llt_shell_helper.sh ~/bin/
chmod +x ~/bin/llt_shell_helper.sh
```

3. Copy the bash completion script:

```bash
cp llt_bash_completion.sh ~/
chmod +x ~/llt_bash_completion.sh
```

4. Add to your `~/.bashrc`:

```bash
echo 'source ~/llt_bash_completion.sh' >> ~/.bashrc
```

5. Apply changes:

```bash
source ~/.bashrc
```

## Usage

1. Type a natural language description of the desired command
2. Press `Ctrl+X` followed by `Ctrl+L`
3. Preview the suggested command
4. Press `Y` to accept or `N` to reject

### Examples

```bash
$ find all python files modified in the last week
[Press Ctrl+X Ctrl+L]
[Preview]: find . -name "*.py" -mtime -7
Use this command? [Y/n]
```

```bash
$ zip all jpg files in current directory
[Press Ctrl+X Ctrl+L]
[Preview]: zip images.zip *.jpg
Use this command? [Y/n]
```

## How It Works

1. When you press `Ctrl+X` followed by `Ctrl+L`, the current line is sent to LLT
2. LLT transforms your natural language description into a bash command
3. The suggested command is displayed below your input
4. You can accept or reject the suggestion
5. If accepted, the suggestion replaces your input

## Performance Optimization

The system includes a caching mechanism to speed up repeated queries:

- Commands are cached based on the MD5 hash of your input
- Cache files older than 30 days are automatically cleaned up
- Files larger than 1MB are purged to prevent storage issues

## Security Considerations

Several security measures are implemented:

- Cache directory permissions are set to 700 (user read/write/execute only)
- Cache files are set to 600 (user read/write only)
- Command syntax is validated before being suggested
- Proper quoting and escaping is applied to prevent injection

## Troubleshooting

### Command Not Found

If you get a "command not found" error when pressing `Ctrl+X` followed by `Ctrl+L`:

1. Make sure LLT is installed and in your PATH
2. Check that the helper script is in `~/bin/llt_shell_helper.sh` and executable
3. Verify that your `~/.bashrc` contains the source line for the completion script

### Incorrect Commands

If the suggested commands are not useful:

1. Be more specific in your natural language description
2. Check that LLT is correctly configured with appropriate models

## Customization

### Changing the Keyboard Shortcut

Edit the `llt_bash_completion.sh` file and modify the `bind` line:

```bash
# Change this line
bind -x '"\C-x\C-l": llm_complete_with_preview'

# To use a different shortcut (e.g., Alt+L)
bind -x '"\el": llm_complete_with_preview'
```

### Using a Different LLT Model

Edit the `llt_shell_helper.sh` file and modify the model parameter:

```bash
# Change this line
RESPONSE=$(llt --non_interactive \
  --model claude-3-sonnet \
  --temperature 0.3 \
  ...
  
# To use a different model
RESPONSE=$(llt --non_interactive \
  --model gpt-4 \
  --temperature 0.3 \
  ...
```

## Maintenance

The system automatically cleans up the cache periodically, but you can manually clear it with:

```bash
find ~/.llt_bash_cache -type f -delete
``` 

If you want to make changes to the llt invocation in llt_shell_helper.sh, make sure to copy the llt_shell_helper.sh file to the bin directory and make it executable. You can do this with our tool.

```bash
$ copy helper script to ~/bin
[Press Ctrl+X Ctrl+L]
[Preview]: cp llt_shell_helper.sh ~/bin/
Use this command? [Y/n]
```

```bash
$ make helper script executable
[Press Ctrl+X Ctrl+L]
[Preview]: chmod +x ~/bin/llt_shell_helper.sh
Use this command? [Y/n]
```