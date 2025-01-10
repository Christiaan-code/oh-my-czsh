# ZSH Configuration Guide

This guide helps you set up a modular ZSH configuration using Oh-My-ZSH.

## Prerequisites

- ZSH shell installed
- Oh-My-ZSH installed
- `$ZSH` environment variable set (typically to `~/.oh-my-zsh`)

## Installation

1. Ensure your `$ZSH` environment variable is set correctly:
```zsh
echo $ZSH
```

2. Create a `.zsh` directory in your home folder:
```zsh
mkdir -p ~/.zsh
```

3. Add the following to your `.zshrc` file:
```zsh
# Source all modular configurations
for config_file in ~/.zsh/**/*.zsh; do
  source $config_file
done
```

## Usage

1. Create new `.zsh` files in the appropriate subdirectories
2. Files will be automatically sourced on shell startup
3. Changes take effect after restarting your shell or running:
```zsh
source ~/.zshrc
```

## Example Configuration

Create a new alias file:
```zsh
# ~/.zsh/aliases/git.zsh
alias gs='git status'
alias gc='git commit'
```

## Troubleshooting

- Ensure file permissions are correct: `chmod 644 ~/.zsh/**/*.zsh`
- Verify files exist: `ls -la ~/.zsh/**/*.zsh`
- Check for syntax errors: `zsh -n ~/.zsh/**/*.zsh`

## Contributing

Feel free to submit issues and enhancement requests.
