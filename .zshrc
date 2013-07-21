# checks {{{
(( UID == 0 )) && isroot=true || isroot=false
# test if command is available
have() { which $1 &>/dev/null || return 1 }
# }}}

# modules {{{
autoload -U compinit edit-command-line vcs_info zmv
compinit
zle -N edit-command-line
zmodload zsh/complist
# }}}

# shell options {{{
setopt nobeep \
    notify \
    nobgnice \
    correct \
    interactivecomments \
    printexitvalue \
    autocd \
    autopushd \
    pushdtohome \
    chaselinks \
    histverify \
    histappend \
    sharehistory \
    histreduceblanks \
    histignorespace \
    histignorealldups \
    histsavenodups \
    braceccl \
    dotglob \
    extendedglob \
    numericglobsort \
    nolisttypes \
    promptsubst \
    completealiases
# input with no command
READNULLCMD=$PAGER
# history
HISTFILE=$ZDOTDIR/.zsh_history
HISTSIZE=10000
SAVEHIST=$HISTSIZE
DIRSTACKSIZE=20
# }}}

# completion style {{{
# menu completion
zstyle ':completion:*' menu select
# colors for file completion
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# complete all processes
zstyle ':completion:*:processes' command 'ps -e'
zstyle ':completion:*:processes-names' command 'ps -eo comm'
# cache completion
zstyle ':completion:*' use-cache on
# don't complete working directory in parent
zstyle ':completion:*' ignore-parents parent pwd
# }}}

# title (for vte, xterm and rxvt) {{{
case "$TERM" in
    vte*|xterm*|rxvt*)
        update_title() { print -Pn '\e];%n (%~) - Terminal\a' } ;;
    *)
        update_title() {} ;;
esac
# }}}

# prompt {{{
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats "%F{green}%b%f "
# initialize vimode (stops linux console glitch)
vimode=i
# set vimode to current editing mode
function zle-line-init zle-keymap-select {
    vimode="${${KEYMAP/vicmd/c}/(main|viins)/i}"
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select
if $isroot; then
	PROMPT='%K{red}%n@%m%k %F{magenta}${vimode}%f %B%F{cyan}%~%b%f ${vcs_info_msg_0_}%B%F{white}%# %b%f'
else
	PROMPT='%K{blue}%n@%m%k %F{magenta}${vimode}%f %B%F{cyan}%~%b%f ${vcs_info_msg_0_}%B%F{white}%# %b%f'
fi
# }}}

# aliases {{{
have colordiff && alias diff=colordiff
alias ls='ls -Ah --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -m'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'
alias ln='ln -iv'
alias install='install -v'
alias mount='mount -v'
alias umount='umount -v'
alias chown='chown -c --preserve-root'
alias chmod='chmod -c --preserve-root'
alias chgrp='chgrp -c --preserve-root'
alias rmdir='rmdir -v'
alias mkdir='mkdir -vp'
alias gdb='gdb -q'
alias p=pacman
alias ll='ls -l'
alias rr='rm -r'
alias pu=pushd
alias po=popd
alias rh=rehash
alias dirs='dirs -p'

# vim
alias vim='vim -p'
alias gvim='gvim -p'
alias vi='vim'
if ! $isroot; then
	alias visudo="sudo EDITOR='$EDITOR' visudo"
    alias vipw="sudo EDITOR='$EDITOR' vipw"
    alias vigr="sudo EDITOR='$EDITOR' vigr"
fi

# bg on empty line, push-input on non-empty line
fancy-ctrl-z() {
    if [[ $#BUFFER -eq 0 ]]; then
		bg
		zle redisplay
	else
		zle push-input
    fi
}
zle -N fancy-ctrl-z

# up-line-or-search with more than the first word
up-line-or-history-beginning-search-backward () {
    if [[ -n $PREBUFFER ]]; then
zle up-line-or-history
    else
zle history-beginning-search-backward
    fi
}
zle -N up-line-or-history-beginning-search-backward

# down-line-or-search with more than the first word
down-line-or-history-beginning-search-forward () {
    if [[ -n $PREBUFFER ]]; then
zle down-line-or-history
    else
zle history-beginning-search-forward
    fi
}
zle -N down-line-or-history-beginning-search-forward
# }}}

# zle keybindings (vim-like) {{{
# make zsh/terminfo work for terms with application and cursor modes
case "$TERM" in
    vte*|xterm*)
        zle-line-init() { zle-keymap-select; echoti smkx }
        zle-line-finish() { echoti rmkx }
        zle -N zle-line-init
        zle -N zle-line-finish
        ;;
esac
# vi editing mode
bindkey -v
# shift-tab
if [[ -n $terminfo[kcbt] ]]; then
bindkey "$terminfo[kcbt]" reverse-menu-complete
fi
# do history expansion on space
bindkey ' ' magic-space
# delete
if [[ -n $terminfo[kdch1] ]]; then
bindkey "$terminfo[kdch1]" delete-char
    bindkey -M vicmd "$terminfo[kdch1]" vi-delete-char
fi
# insert
if [[ -n $terminfo[kich1] ]]; then
bindkey "$terminfo[kich1]" overwrite-mode
    bindkey -M vicmd "$terminfo[kich1]" vi-insert
fi
# home
if [[ -n $terminfo[khome] ]]; then
bindkey "$terminfo[khome]" vi-beginning-of-line
    bindkey -M vicmd "$terminfo[khome]" vi-beginning-of-line
fi
# end
if [[ -n $terminfo[kend] ]]; then
bindkey "$terminfo[kend]" vi-end-of-line
    bindkey -M vicmd "$terminfo[kend]" vi-end-of-line
fi
# backspace (and <C-h>)
if [[ -n $terminfo[kbs] ]]; then
bindkey "$terminfo[kbs]" backward-delete-char
    bindkey -M vicmd "$terminfo[kbs]" backward-char
fi
bindkey '^H' backward-delete-char
bindkey -M vicmd '^H' backward-char
# page up (and <C-b> in vicmd)
if [[ -n $terminfo[kpp] ]]; then
bindkey "$terminfo[kpp]" beginning-of-buffer-or-history
    bindkey -M vicmd "$terminfo[kpp]" beginning-of-buffer-or-history
fi
bindkey -M vicmd '^B' beginning-of-buffer-or-history
# page down (and <C-f> in vicmd)
if [[ -n $terminfo[knp] ]]; then
bindkey "$terminfo[knp]" end-of-buffer-or-history
    bindkey -M vicmd "$terminfo[knp]" end-of-buffer-or-history
fi
bindkey -M vicmd '^F' end-of-buffer-or-history
# up arrow (history search)
if [[ -n $terminfo[kcuu1] ]]; then
bindkey "$terminfo[kcuu1]" up-line-or-history-beginning-search-backward
    bindkey -M vicmd "$terminfo[kcuu1]" up-line-or-history-beginning-search-backward
fi
# down arrow (history search)
if [[ -n $terminfo[kcud1] ]]; then
bindkey "$terminfo[kcud1]" down-line-or-history-beginning-search-forward
    bindkey -M vicmd "$terminfo[kcud1]" down-line-or-history-beginning-search-forward
fi
# left arrow (whichwrap)
if [[ -n $terminfo[kcub1] ]]; then
bindkey "$terminfo[kcub1]" backward-char
    bindkey -M vicmd "$terminfo[kcub1]" backward-char
fi
# right arrow (whichwrap)
if [[ -n $terminfo[kcuf1] ]]; then
bindkey "$terminfo[kcuf1]" forward-char
    bindkey -M vicmd "$terminfo[kcuf1]" forward-char
fi
# shift-left
if [[ -n $terminfo[kLFT] ]]; then
bindkey "$terminfo[kLFT]" vi-backward-word
    bindkey -M vicmd "$terminfo[kLFT]" vi-backward-word
fi
# shift-right
if [[ -n $terminfo[kRIT] ]]; then
bindkey "$terminfo[kRIT]" vi-forward-word
    bindkey -M vicmd "$terminfo[kRIT]" vi-forward-word
fi
# ctrl-left
bindkey '^[[1;5D' vi-backward-blank-word
# ctrl-right
bindkey '^[[1;5C' vi-forward-blank-word
# no vi-backward-kill-word
bindkey '^W' backward-kill-word
# h and l whichwrap
bindkey -M vicmd 'h' backward-char
bindkey -M vicmd 'l' forward-char
# incremental undo and redo
bindkey -M vicmd '^R' redo
bindkey -M vicmd 'u' undo
# misc
bindkey -M vicmd 'ga' what-cursor-position
# open in editor
bindkey -M vicmd 'v' edit-command-line
# fancy <C-z>
bindkey '^Z' fancy-ctrl-z
bindkey -M vicmd '^Z' fancy-ctrl-z
# }}}

# cleanup {{{
unset isroot app
# }}}

