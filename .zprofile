# test if command is available
have() { which $1 &>/dev/null || return 1 }

# set secure umask
umask 077

# constant environment variables {{{
export PATH="$PATH:$HOME/.local/bin"

# man page colors in less
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# disable less history file
export LESSHISTFILE=-

# highest compression
export GZIP=-9 \
  BZIP=-9 \
  XZ_OPT=-9

# colors
eval $(dircolors -b ~/.config/dircolors)

# }}}

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
