# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# 秘匿環境変数(SSOT: repo直下.envを~/.config symlink経由で読込)
# Why: zsh/.zshrcと同じ~/.config/.envを共有。linkがない環境では単にスキップ
[ -f ~/.config/.env ] && . ~/.config/.env

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote:01'

# Completion: case-insensitive match
# Why: zsh側smartcase補完のbash版。bash(readline)にsmartcase相当の
#      片方向マッチは存在せず、完全な大小無視のみ可能
bind 'set completion-ignore-case on'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias code='coderm'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
if command -v notify-send &> /dev/null; then
    alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# =============================================================================
# OS-specific settings
# =============================================================================

# fnm (Fast Node Manager)
eval "$(fnm env --use-on-cd)"

# Claude alias
# 【注意】コメントアウト中
# 理由: ccはUnix/macOSにおけるCコンパイラのコマンド名と衝突する
# ビルドツールが裏でccを呼ぶたびにClaude Codeが起動し、
# PCがハングする原因になる。参照: https://zenn.dev/owayo/articles/6190821ac1dd1e
# alias cc='claude'

# OpenCode alias
# 【注意】コメントアウト中
# 理由: ccエイリアスと統一するため（ccはCコンパイラと衝突するため無効化）
# oc自体は既存コマンドと衝突しないが、短縮エイリアス運用を中止
# alias oc='opencode'

if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # =========================================================================
    # Windows (Git Bash) specific
    # =========================================================================

    # fnm PATH (WinGet)
    export PATH="$PATH:$HOME/AppData/Local/Microsoft/WinGet/Links"

    # tmux setup for Git Bash (Windows)
    # 1. Download MSYS2 tmux binaries from: https://github.com/microsoft/terminal/issues/1524
    # 2. Extract and place in /e/tools/tmux/ (or any preferred location)
    # 3. Add to PATH below
    export PATH="/e/tools/tmux:$PATH"

    # tmux with unique socket per terminal
    alias tmux='tmux -L "term$$"'

    # jq (JSON processor)
    export PATH="/e/tools:$PATH"

    # Auto-start tmux (Windows Terminal, VS Code, etc.)
    if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
      exec tmux -L "term$$" new-session
    fi

    # GitHub CLI setup
    # Install: winget install GitHub.cli
    export PATH="$PATH:/c/Program Files/GitHub CLI"

elif [[ "$OSTYPE" == "darwin"* ]]; then
    # =========================================================================
    # macOS specific
    # =========================================================================
    :

else
    # =========================================================================
    # Linux specific
    # =========================================================================
    :

fi

# =============================================================================
# Starship prompt
# =============================================================================
# Install:
#   macOS:   brew install starship
#   Windows: winget install starship
#   Linux:   curl -sS https://starship.rs/install.sh | sh
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

# =============================================================================
# fzf - fuzzy finder
# =============================================================================
# Install:
#   macOS:   brew install fzf
#   Windows: winget install fzf
#   Linux:   git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
# Keybinds: CTRL-R (history), CTRL-T (files), ALT-C (cd)
if command -v fzf &> /dev/null; then
    eval "$(fzf --bash)"
fi

