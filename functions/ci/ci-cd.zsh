#!/usr/bin/env zsh

# Setup Husky with pre-push hook and version management scripts
setup-ci-cd() {
    local target_dir="${1:-.}"
    
    # Convert to absolute path
    target_dir=$(cd "$target_dir" && pwd)
    
    echo "🔧 Setting up Husky in: $target_dir"
    
    # Check if package.json exists
    if [[ ! -f "$target_dir/package.json" ]]; then
        echo "❌ Error: package.json not found in $target_dir"
        return 1
    fi
    
    # Create .husky directory if it doesn't exist
    local husky_dir="$target_dir/.husky"
    if [[ ! -d "$husky_dir" ]]; then
        echo "📁 Creating .husky directory..."
        mkdir -p "$husky_dir"
    fi
    
    # Install husky dependency
    echo "📦 Installing husky..."
    cd "$target_dir"
    yarn add husky
    
    if [[ $? -ne 0 ]]; then
        echo "❌ Error installing husky"
        return 1
    fi
    
    # Copy pre-push hook
    local pre_push_source="$HOME/.zsh/functions/ci/pre-push"
    local pre_push_target="$husky_dir/pre-push"
    
    echo "📋 Copying pre-push hook..."
    cp "$pre_push_source" "$pre_push_target"
    chmod +x "$pre_push_target"
    
    # Update package.json with required scripts
    echo "📦 Updating package.json scripts..."
    
    # Use node to update package.json
    node -e "
        const fs = require('fs')
        const path = '$target_dir/package.json'
        const pkg = JSON.parse(fs.readFileSync(path, 'utf8'))
        
        // Initialize scripts object if it doesn't exist
        if (!pkg.scripts) {
            pkg.scripts = {}
        }
        
        // Add version management scripts
        pkg.scripts['version:patch'] = 'npm version patch -m \"chore(release): bump version to %s\"'
        pkg.scripts['version:minor'] = 'npm version minor -m \"chore(release): bump version to %s\"'
        pkg.scripts['version:major'] = 'npm version major -m \"chore(release): bump version to %s\"'
        pkg.scripts['version:check'] = 'echo \"Current version: \$(node -p \\\"require(\\\"./package.json\\\").version\\\")\"\''
        pkg.scripts['build:multi'] = 'zsh -c \\'source ~/.zshrc && build-multiplatform --auto\\''
        pkg.scripts['prepare'] = 'husky'
        
        // Write back to file with proper formatting
        fs.writeFileSync(path, JSON.stringify(pkg, null, 2) + '\n')
        
        console.log('✅ Added version management scripts to package.json')
    "
    
    if [[ $? -eq 0 ]]; then
        # Initialize husky hooks
        echo "🔧 Initializing husky hooks..."
        yarn prepare
        
        if [[ $? -eq 0 ]]; then
            echo ""
            echo "🎉 CI/CD setup complete!"
            echo "📋 Added scripts:"
            echo "   • version:patch - Bump patch version"
            echo "   • version:minor - Bump minor version" 
            echo "   • version:major - Bump major version"
            echo "   • version:check - Check current version"
            echo "   • build:multi - Build multiplatform Docker images"
            echo "   • prepare - Initialize husky"
            echo ""
            echo "📁 Files created/updated:"
            echo "   • $husky_dir/pre-push"
            echo "   • $target_dir/package.json"
            echo ""
            echo "✅ Everything is ready! Your pre-push hook will now prompt for version bumps before each push."
        else
            echo "❌ Error initializing husky hooks"
            return 1
        fi
    else
        echo "❌ Error updating package.json"
        return 1
    fi
}

# Alias for convenience
alias ci-cd-setup='setup-ci-cd'
