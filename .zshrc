# MIT License
# Copyright (c) 2018 Julien Schmidt
# https://github.com/julienschmidt/dotfiles

# Install recommended (optional) dependencies:
#
# Debian/Ubuntu:
# apt install command-not-found curl zsh-syntax-highlighting
#
# MacOS with brew:
# brew install zsh-syntax-highlighting


##
# General ZSH Options
##
setopt extended_glob            # activate complex pattern globbing
setopt glob_dots                # include dotfiles in globbing

setopt auto_pushd               # make cd push the old directory onto the directory stack.
setopt pushd_ignore_dups        # don't push the same dir twice.

setopt auto_cd                  # if command is a path, cd into it
setopt auto_remove_slash        # self explicit
setopt chase_links              # resolve symlinks
setopt correct                  # try to correct spelling of commands

#setopt longlistjobs             # display PID when suspending processes as well
setopt nobeep                   # avoid "beep"ing
setopt nohup                    # Don't send SIGHUP to background processes when the shell exits.
setopt nonomatch                # try to avoid the 'zsh: no matches found...'
setopt notify                   # report the status of backgrounds jobs immediately
#setopt print_exit_value         # print return value if non-zero

setopt clobber                  # must use >| to truncate existing files
unsetopt hist_beep              # no bell on error in history
unsetopt ignore_eof             # do not exit on end-of-file
unsetopt list_beep              # no bell on ambiguous completion
unsetopt rm_star_silent         # ask for confirmation for `rm *' or `rm path/*'


# colors
autoload -Uz colors && colors

##
# History
##

if [ -z "$HISTFILE" ]; then
    HISTFILE=$HOME/.zsh_history
fi
HISTSIZE=10000
SAVEHIST=10000

setopt append_history           # append
setopt hist_ignore_all_dups     # no duplicate
setopt histignorespace          # ignore space prefixed commands
setopt hist_reduce_blanks       # trim blanks
setopt hist_verify              # show before executing history commands
setopt inc_append_history       # add commands as they are typed, don't wait until shell exit
setopt share_history            # share hist between sessions
unsetopt bang_hist              # make ! work as one would expect


##
# Completion
##
if type brew &>/dev/null; then
  BREWPREFIX=$(brew --prefix)
  FPATH=$BREWPREFIX/share/zsh/site-functions:$BREWPREFIX/share/zsh-completions:$FPATH
fi

autoload -Uz compinit && compinit -i
zmodload -i zsh/complist
setopt hash_list_all            # hash everything before completion
setopt always_to_end            # when completing from the middle of a word, move the cursor to the end of the word
setopt complete_in_word         # allow completion from within a word/phrase
setopt list_ambiguous           # complete as much of a completion until it gets ambiguous.

zstyle ':completion::complete:*' use-cache on               # completion caching, use rehash to clear
zstyle ':completion:*' cache-path ~/.zsh/cache              # cache path
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # ignore case
zstyle ':completion:*' menu select=2                        # menu if nb items > 2
zstyle ':completion:*' list-colors ''
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate # list of completers to use
zstyle ':completion:*' accept-exact '*(N)'

# sections completion !
# zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format $'\e[00;34m%d'
zstyle ':completion:*:messages' format $'\e[00;31m%d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:manuals' separate-sections true

zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=29=34"
zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*' force-list always

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show

#generic completion with --help
# use generic completion system for programs not yet defined; (_gnu_generic works
# with commands that provide a --help option with "standard" gnu-like output.)
for compcom in cp deborphan df feh fetchipac gcc gpasswd head hnb ipacsum mv \
               openssl pal r2 stow tail uname ; do
    [[ -z ${_comps[$compcom]} ]] && compdef _gnu_generic ${compcom}
done; unset compcom


##
# VCS info
##
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '!'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:*' formats " %B[%{$fg[yellow]%}%b%{$fg[green]%}%m%{$fg[red]%}%c%u%{$fg[cyan]%}%{$reset_color%}%B]"
zstyle ':vcs_info:*' actionformats " %B%{$fg[magenta]%}[%{$fg[yellow]%}%b%{$reset_color%}~%{$fg[red]%}%a%{$fg[magenta]%}]%{$reset_color%}"
precmd() {  # run before each prompt
  vcs_info
}


##
# Prompt
##
setopt prompt_subst

# left-side
# return code
PROMPT='%B%F{red}%(?..%? )%f%b'

# if a virtualenv is activated, display it in grey
PROMPT+='%(12V.%F{242}%12v%f .)'

# user
USERCOLOR="blue"
#PROMPTSYMBOL='❯'
PROMPTSYMBOL='$'
if (( EUID == 0 )); then
    USERCOLOR="red"
    PROMPTSYMBOL='#'
fi;
PROMPT+='%B%{$fg[$USERCOLOR]%}%n%{$reset_color%}%b'

# add host if connected via ssh
if [[ -n "$SSH_CONNECTION" || -n "$SSH_TTY" || -n "$SSH_CLIENT" ]]; then
    PROMPT+='@%m'
elif [[ -x `which systemd-detect-virt` ]] && systemd-detect-virt --quiet; then
    PROMPT+='@%{$fg[yellow]%}%m%{$reset_color%}%b'
fi;
PROMPT+=':%B%40<..<%~%<<${vcs_info_msg_0_} %{$fg[cyan]%}$PROMPTSYMBOL%{$reset_color%}%b '

# right-side
RPROMPT='%T' # show time


##
# Terminal Support
##
# Set terminal window and tab/icon title
#
# usage: title short_tab_title [long_window_title]
#
# stolen from oh-my-zsh:
# https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/termsupport.zsh
#
# See: http://www.faqs.org/docs/Linux-mini/Xterm-Title.html#ss3.1
# Fully supports screen, iterm, and probably most modern xterm and rxvt
# (In screen, only short_tab_title is used)
# Limited support for Apple Terminal (Terminal can't set window and tab separately)
function title {
  emulate -L zsh
  setopt prompt_subst

  [[ "$EMACS" == *term* ]] && return

  # if $2 is unset use $1 as default
  # if it is set and empty, leave it as is
  : ${2=$1}

  case "$TERM" in
    cygwin|xterm*|putty*|rxvt*|ansi)
      print -Pn "\e]2;$2:q\a" # set window name
      print -Pn "\e]1;$1:q\a" # set tab name
      ;;
    screen*)
      print -Pn "\ek$1:q\e\\" # set screen hardstatus
      ;;
    *)
      if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
        print -Pn "\e]2;$2:q\a" # set window name
        print -Pn "\e]1;$1:q\a" # set tab name
      else
        # Try to use terminfo to set the title
        # If the feature is available set title
        if [[ -n "$terminfo[fsl]" ]] && [[ -n "$terminfo[tsl]" ]]; then
    echoti tsl
    print -Pn "$1"
    echoti fsl
  fi
      fi
      ;;
  esac
}

ZSH_THEME_TERM_TAB_TITLE_IDLE="%15<..<%~%<<" #15 char left truncated PWD
if [[ -n "$SSH_CONNECTION" || -n "$SSH_TTY" || -n "$SSH_CLIENT" ]]; then
  ZSH_THEME_TERM_TAB_TITLE_IDLE+="@%m"
fi

ZSH_THEME_TERM_TITLE_IDLE="%n@%m: %~"
# Avoid duplication of directory in terminals with independent dir display
if [[ $TERM_PROGRAM == Apple_Terminal ]]; then
  ZSH_THEME_TERM_TITLE_IDLE="%n@%m"
fi

# ssh with tmux integration
# attach to session 'julien' if it already exists or create it.
function ssht {
  ssh -t $@ "tmux -CC new -A -s julien";
}
_ssht () {
  local service=ssh
  _ssh "$@"
}
compdef _ssht ssht


# Runs before showing the prompt
function z_termsupport_precmd {
  emulate -L zsh
  if [[ $DISABLE_AUTO_TITLE == true ]]; then
    return
  fi

  title $ZSH_THEME_TERM_TAB_TITLE_IDLE $ZSH_THEME_TERM_TITLE_IDLE
}

# Runs before executing the command
function z_termsupport_preexec {
  emulate -L zsh
  if [[ $DISABLE_AUTO_TITLE == true ]]; then
    return
  fi

  #setopt extended_glob

  # cmd name only, or if this is sudo or ssh, the next cmd
  local CMD=${1[(wr)^(*=*|sudo|ssh|mosh|rake|-*)]:gs/%/%%}
  local LINE="${2:gs/%/%%}"

  title '$CMD' '%100>...>$LINE%<<'
}

precmd_functions+=(z_termsupport_precmd)
preexec_functions+=(z_termsupport_preexec)


##
# ZSH Syntax Highlighting
##
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
if [[ -a /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -a /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi


##
# command-not-found
#
# Linux only. While for MacOS there is
# https://github.com/Homebrew/homebrew-command-not-found it is not used as it
# is waaay too slow.
##
if [[ -x /usr/lib/command-not-found ]] ; then
  if (( ! ${+functions[command_not_found_handler]} )) ; then
    function command_not_found_handler {
      [[ -x /usr/lib/command-not-found ]] || return 1
      /usr/lib/command-not-found --no-failure-msg -- ${1+"$1"} && :
    }
  fi
fi

##
# Conf Update
##
function update-conf {
  local conf_base='https://raw.githubusercontent.com/julienschmidt/dotfiles/master/'

  if [[ -z "$1"  || -n "$2" ]]; then
    echo "Usage: update-conf <conf file>"
    return 1
  fi

  if [[ -x `which curl` ]]; then
    curl -f -o ~/$1.new $conf_base$1
  elif [[ -x `which wget` ]]; then
    wget -O ~/$1.new $conf_base$1
  else
    echo "ERROR: Please install curl or wget!"
    return 1
  fi

  if [ $? -ne 0 ]; then
    echo "ERROR: Downloading conf file '$1' failed!"
    return 1
  fi

  if [[ -f ~/$1 ]]; then
    echo "Saving old '$1' to '$1.old' ..."
    mv ~/$1 ~/$1.old
  fi
  echo "Renaming '$1.new' to '$1' ..."
  mv ~/$1.new ~/$1
}

alias update-zshrc='update-conf .zshrc && . ~/.zshrc'

##
# Key Bindings
##
# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="$terminfo[khome]"
key[End]="$terminfo[kend]"
key[Insert]="$terminfo[kich1]"
key[Backspace]="$terminfo[kbs]"
key[Delete]="$terminfo[kdch1]"
key[Up]="$terminfo[kcuu1]"
key[Down]="$terminfo[kcud1]"
key[Left]="$terminfo[kcub1]"
key[Right]="$terminfo[kcuf1]"
key[PageUp]="$terminfo[kpp]"
key[PageDown]="$terminfo[knp]"

# setup key accordingly
[[ -n "$key[Home]"      ]] && bindkey -- "$key[Home]"      beginning-of-line
[[ -n "$key[End]"       ]] && bindkey -- "$key[End]"       end-of-line
[[ -n "$key[Insert]"    ]] && bindkey -- "$key[Insert]"    overwrite-mode
[[ -n "$key[Backspace]" ]] && bindkey -- "$key[Backspace]" backward-delete-char
[[ -n "$key[Delete]"    ]] && bindkey -- "$key[Delete]"    delete-char
[[ -n "$key[Up]"        ]] && bindkey -- "$key[Up]"        history-search-backward # start typing + [Up-Arrow] - fuzzy find history forward
[[ -n "$key[Down]"      ]] && bindkey -- "$key[Down]"      history-search-forward  # start typing + [Down-Arrow] - fuzzy find history backward
[[ -n "$key[PageUp]"    ]] && bindkey -- "$key[PageUp]"    up-line-or-history      # Up a line of history
[[ -n "$key[PageDown]"  ]] && bindkey -- "$key[PageDown]"  down-line-or-history    # Down a line of history
[[ -n "$key[Left]"      ]] && bindkey -- "$key[Left]"      backward-char
[[ -n "$key[Right]"     ]] && bindkey -- "$key[Right]"     forward-char

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init () {
        echoti smkx
    }
    function zle-line-finish () {
        echoti rmkx
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi

bindkey ' ' magic-space                               # [Space] - do history expansion

bindkey "[C" forward-word
bindkey "[D" backward-word
bindkey "^[[1;9H" backward-word                       # [Fn-Option-Left], [Option-Home] - move backward one word
bindkey "^[[1;9F" forward-word                        # [Fn-Option-Right], [Option-End] - move forward one word
bindkey '^[[1;5D' backward-word                       # [Ctrl-LeftArrow] - move backward one word
bindkey '^[[1;5C' forward-word                        # [Ctrl-RightArrow] - move forward one word

if [[ "${terminfo[kcbt]}" != "" ]]; then
  bindkey "${terminfo[kcbt]}" reverse-menu-complete   # [Shift-Tab] - move through the completion menu backwards
fi

bindkey "^K"      kill-whole-line                      # ctrl-k
bindkey "^R"      history-incremental-search-backward  # ctrl-r
bindkey "^A"      beginning-of-line                    # ctrl-a
bindkey "^E"      end-of-line                          # ctrl-e
bindkey "^D"      delete-char                          # ctrl-d
bindkey "^F"      forward-char                         # ctrl-f
bindkey "^B"      backward-char                        # ctrl-b
bindkey -e


##
# Aliases
##
typeset -ga ls_options
typeset -ga grep_options
if ls --color=auto / >/dev/null 2>&1; then
    ls_options=( --color=auto )
elif ls -G / >/dev/null 2>&1; then
    ls_options=( -G )
fi
if grep --color=auto -q "a" <<< "a" >/dev/null 2>&1; then
    grep_options=( --color=auto )
fi
# do we have GNU ls with color-support?
if [[ "$TERM" != dumb ]]; then
    #a1# List files with colors (\kbd{ls -F \ldots})
    alias ls='command ls -F '${ls_options:+"${ls_options[*]}"}
    #a1# List all files, with colors (\kbd{ls -la \ldots})
    alias la='command ls -la '${ls_options:+"${ls_options[*]}"}
    #a1# List files with long colored list, without dotfiles (\kbd{ls -l \ldots})
    alias ll='command ls -l '${ls_options:+"${ls_options[*]}"}
    #a1# List files with long colored list, human readable sizes (\kbd{ls -hAl \ldots})
    alias lh='command ls -hAl '${ls_options:+"${ls_options[*]}"}
    #a1# List files with long colored list, append qualifier to filenames (\kbd{ls -lF \ldots})\\&\quad(\kbd{/} for directories, \kbd{@} for symlinks ...)
    alias l='command ls -lF '${ls_options:+"${ls_options[*]}"}
else
    alias ls='command ls -F'
    alias la='command ls -la'
    alias ll='command ls -l'
    alias lh='command ls -hAl'
    alias l='command ls -lF'
fi

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias d='dirs -v | head -10'
alias 1='cd -'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

alias ip='command ip --color'
alias ipb='command ip --color --brief'

alias fstab='command cat /etc/fstab'
alias mdstat='command cat /proc/mdstat'

alias please="sudo"

# systemd
alias start='command systemctl start'
alias stop='command systemctl stop'
alias reload='command systemctl reload'
alias restart='command systemctl restart'
alias status='command systemctl status'
alias journal='command journalctl -f -n 100 -u'


##
# Various
##


# limit text width of man pages to 80 chars
export MANWIDTH=80

# default locales
export LC_ALL=en_US.utf8
export LANGUAGE=en_US.utf8

# color setup for ls
if [ -x /usr/bin/dircolors ]
then
  if [ -r ~/.dir_colors ]
  then
    eval "`dircolors ~/.dir_colors`"
  elif [ -r /etc/dir_colors ]
  then
    eval "`dircolors /etc/dir_colors`"
  else
    eval "`dircolors`"
  fi
fi
export CLICOLOR=1
export LSCOLORS="Gxfxcxdxbxegedabagacad"

# support colors in less
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

export GCC_COLORS=1

# use colors when GNU grep with color-support
if (( $#grep_options > 0 )); then
    o=${grep_options:+"${grep_options[*]}"}
    #a2# Execute \kbd{grep -{}-color=auto}
    alias grep='grep '$o
    alias egrep='egrep '$o
    unset o
fi

# if we don't set $SHELL then aterm, rxvt,.. will use /bin/sh or /bin/bash :-/
if [[ -z "$SHELL" ]] ; then
  SHELL="$(which zsh)"
  if [[ -x "$SHELL" ]] ; then
    export SHELL
  fi
fi

# Use nano and subl if graphics is available
export EDITOR="nano"
if [[ -x `which subl` ]]; then
    export VISUAL="subl -n -w"
    alias edit='subl'
    alias e='subl'
    git config --global core.editor "subl -n -w"
else
    alias edit='nano'
    alias subl='nano'
    alias e='nano'
fi

export PAGER='less'

# macOS stuff
if [[ $(uname) = 'Darwin' ]]; then
    if [[ -x `which brew` ]]; then
        # No Gurgle Analytics in brew
        export HOMEBREW_NO_ANALYTICS=1

        # ¯\_(ツ)_/¯
        alias apt='brew'
    fi

    # iTerm integration
    if [[ -a "~/.iterm2_shell_integration.zsh" ]]; then
        source ~/.iterm2_shell_integration.zsh
    fi
fi

# Go stuff
export GOBIN=/usr/local/bin
export GOPATH=/usr/local/src/go

# Include local stuff
if [[ -a ~/.zshrc.local ]]; then
    source ~/.zshrc.local
fi
