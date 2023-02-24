# key bind
alias ll 'exa -l -a -g --icons --ignore-glob=".DS_Store|.localized" --sort=type --time-style=long-iso'
alias vim 'nvim'
alias chrome="open -a 'Google Chrome'"
alias powerpoint="open -a 'Microsoft PowerPoint'"


# path
set -gx PATH /opt/homebrew/bin $PATH
# set -gx PATH $HOME/.nodebrew/current/bin $PATH
set -gx PATH $HOME/work/software/flutter/bin $PATH
set -gx PATH $HOME/work/software/flutter/.pub-cache/bin $PATH
set -gx PYENV_PATH $HOME/.pyenv
set -gx EDITOR nvim
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx PATH $HOME/.pub-cache/bin $PATH
set -U fish_user_paths $fish_user_paths $HOME/.cargo/bin


# appium
set -gx ANDROID_HOME $HOME/Library/Android/sdk $ANDROID_HOME
set -gx PATH $ANDROID_HOME/platform-tools $PATH
set -gx JAVA_HOME /Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home $JAVA_HOME
set -gx PATH $JAVA_HOME/bin $PATH

# fish theme
set -g theme_color_scheme terminal-dark
set -g fish_prompt_pwd_dir_length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always

set -gx TERM xterm-256color
set fish_greeting ""

# peco
function fish_user_key_bindings
    bind \cr peco_select_history
end

# fish-yvm
for i in functions completions
  curl https://raw.githubusercontent.com/cideM/fish-yvm/master/$i/yvm.fish --create-dirs -sLo $XDG_CONFIG_HOME/fish/$i/yvm.fish
end

# pyenv-virtualenv
# status --is-interactive; and pyenv virtualenv-init - | source
