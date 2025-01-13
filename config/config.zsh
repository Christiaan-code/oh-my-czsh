source ~/.zsh/config/plugins/plugins.zsh
for theme_file in ~/.zsh/config/themes/**/*.zsh; do
  source $theme_file
done

source $ZSH/oh-my-zsh.sh
source $(brew --prefix nvm)/nvm.sh
PATH=~/.console-ninja/.bin:$PATH

source ~/.zsh/config/exports/exports.zsh
