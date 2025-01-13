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

3. Add a symbolic link to the `.zshrc` file in your home directory:
```zsh
ln -s ~/.zsh/.zshrc .zshrc
```

4. Add the following to your `.zshrc` file:
```zsh
# Source main configuration file
source ~/.zsh/config/config.zsh

# Source all other modular configurations (excluding root config directory)
for config_file in ~/.zsh/^config/*.zsh(N); do
  source $config_file
done
```

## Directory Structure

Everything that has to do with configuration should be in the `config` directory,
and explicitly sourced in the appropriate order in the `config.zsh` file.

All other files should be in the root directory, and will automatically be sourced by the `.zshrc` file.

## Usage

1. Create new `.zsh` files in the appropriate subdirectories
2. Files will be automatically sourced on shell startup
3. Changes take effect after restarting your shell or running:
```zsh
source ~/.zshrc
```

## Example Configuration

Create a new function file:
```zsh
# ~/.zsh/functions/status.zsh
function status() {
  echo "Status: $(git status)"
}
```

## Troubleshooting

- Ensure file permissions are correct: `chmod 644 ~/.zsh/**/*.zsh`
- Verify files exist: `ls -la ~/.zsh/**/*.zsh`
- Check for syntax errors: `zsh -n ~/.zsh/**/*.zsh`

## Contributing

Feel free to submit issues and enhancement requests.
