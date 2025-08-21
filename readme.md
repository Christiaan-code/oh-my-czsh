# ZSH Configuration Guide

This guide helps you set up a modular ZSH configuration with some cool features using Oh-My-ZSH. I call it Christiaan's ZSH (or CZSH for short).

## Prerequisites

- ZSH shell installed
- Oh-My-ZSH installed
- `$ZSH` environment variable set (typically to `~/.oh-my-zsh`)

## Installation

1. Ensure your `$ZSH` environment variable is set correctly:
```zsh
echo $ZSH
```

2. Clone the ZSH configuration repository:
```zsh
git clone https://github.com/Christiaan-code/oh-my-czsh.git ~/.zsh
```

3. Add a symbolic link to the `.zshrc` file in your home directory:
```zsh
ln -s ~/.zshrc .zshrc
```

4. Add the following to your `.zshrc` file:
```zsh
# Source main configuration file
source ~/.zsh/config/config.zsh

# Source all other modular configurations (excluding root config directory)
for config_file in ~/.zsh/**/*.zsh(N); do
  # Skip files in the config directory as they're sourced via config.zsh
  if [[ $config_file != *"/config/"* ]]; then
    source $config_file
  fi
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

## Terminal Configuration

### iTerm2 Installation

For an enhanced terminal experience, we recommend installing [iTerm2](https://iterm2.com/downloads.html).

To install:
1. Download iTerm2 from the [official downloads page](https://iterm2.com/downloads.html)
2. Extract the downloaded file
3. Move iTerm.app to your Applications folder

### Terminal Preferences

You can configure your preferred terminal using the `configure-zsh` command:

```bash
configure-zsh
```

This interactive command allows you to:
- Choose between System Terminal and iTerm2 as your default terminal
- Settings are saved to `~/.zsh/config/preferences/preferences.config.zsh`
- Configuration is automatically loaded on shell startup

The selected preferences will be used by various scripts and commands throughout the system.

## Troubleshooting

- Ensure file permissions are correct: `chmod 644 ~/.zsh/**/*.zsh`
- Verify files exist: `ls -la ~/.zsh/**/*.zsh`
- Check for syntax errors: `zsh -n ~/.zsh/**/*.zsh`

## Contributing

Feel free to submit issues and enhancement requests.
