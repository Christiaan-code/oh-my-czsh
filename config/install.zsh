#!/usr/bin/env zsh

# CZSH Installation Script
# Automates steps 3, 4, and 5 from the installation guide

# ZSH options
setopt ERR_EXIT  # Exit on any error
setopt PIPE_FAIL # Fail if any command in a pipeline fails

print "🚀 Starting CZSH installation automation..."

# Colors for output using ZSH's built-in color support
autoload -U colors && colors

# Function to print colored output using ZSH colors
print_status() {
    print "${fg[blue]}[INFO]${reset_color} $1"
}

print_success() {
    print "${fg[green]}[SUCCESS]${reset_color} $1"
}

print_warning() {
    print "${fg[yellow]}[WARNING]${reset_color} $1"
}

print_error() {
    print "${fg[red]}[ERROR]${reset_color} $1"
}

# Step 3: Create symbolic link to .zshrc
print_status "Creating symbolic link to .zshrc..."

if [[ -L "$HOME/.zsh/.zshrc" ]]; then
    print_warning ".zshrc symbolic link already exists"
elif [[ -f "$HOME/.zsh/.zshrc" ]]; then
    print_warning "Backing up existing .zshrc to .zshrc.backup"
    cp "$HOME/.zsh/.zshrc" "$HOME/.zsh/.zshrc.backup"
    rm "$HOME/.zsh/.zshrc"
    ln -s "$HOME/.zsh/.zshrc" "$HOME/.zsh/.zshrc"
    print_success "Created symbolic link and backed up original .zshrc"
else
    ln -s "$HOME/.zsh/.zshrc" "$HOME/.zsh/.zshrc"
    print_success "Created symbolic link to .zshrc"
fi

# Step 4: Add configuration to .zshrc
print_status "Updating .zshrc with CZSH configuration..."

# ZSH heredoc syntax for multi-line content
local zshrc_content=$(cat <<'EOF'
# Source main configuration file
source ~/.zsh/config/config.zsh

# Source all other modular configurations (excluding root config directory)
for config_file in ~/.zsh/**/*.zsh(N); do
  # Skip files in the config directory as they're sourced via config.zsh
  if [[ $config_file != *"/config/"* ]]; then
    source $config_file
  fi
done
EOF
)

# Check if the configuration is already present using ZSH pattern matching
if [[ -f "$HOME/.zsh/.zshrc" ]] && grep -q "source ~/.zsh/config/config.zsh" "$HOME/.zsh/.zshrc" 2>/dev/null; then
    print_warning "CZSH configuration already present in .zshrc"
else
    # Create or update .zshrc with the configuration
    print $zshrc_content > "$HOME/.zsh/.zshrc"
    print_success "Added CZSH configuration to .zshrc"
fi

# Step 5: Create projects.config.zsh file
print_status "Creating projects.config.zsh file..."

local projects_config_dir="$HOME/.zsh/functions/projects"
local projects_config_file="$projects_config_dir/projects.config.zsh"

# Ensure the directory exists using ZSH syntax
[[ ! -d "$projects_config_dir" ]] && mkdir -p "$projects_config_dir"

if [[ -f "$projects_config_file" ]]; then
    print_warning "projects.config.zsh already exists"
else
    print '# PROJECTS[alias]="path|node:version(optional)|run_command1;run_command2;..."' > "$projects_config_file"
    print_success "Created projects.config.zsh file"
fi

print_success "🎉 CZSH installation automation completed!"
print
print_status "Next steps:"
print "  1. Restart your shell or run: source ~/.zsh/.zshrc"
print "  2. Configure your terminal preferences with: configure-zsh"
print "  3. Add your project configurations to: $projects_config_file"
print
print_status "For more information, see the README.md file"
