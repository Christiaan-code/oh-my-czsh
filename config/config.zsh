source ~/jobjack/oh-my-czsh/config/preferences/configure-zsh.zsh
source ~/jobjack/oh-my-czsh/config/plugins/plugins.zsh
for theme_file in ~/jobjack/oh-my-czsh/config/themes/**/*.zsh; do
  source $theme_file
done

source ~/jobjack/oh-my-czsh/config/exports/exports.zsh

source $ZSH/oh-my-zsh.sh
source $(brew --prefix nvm)/nvm.sh
PATH=~/.console-ninja/.bin:$PATH
