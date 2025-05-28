if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
  exec startx
fi

setxkbmap fr 
fastfetch
source ~/.local/.ads-env
source ~/.local/.local-infra-env
source ~/.fzfrc
export EDITOR=nvim
PROMPT="%F{blue}┌[%f%F{cyan}%m%f%F{blue}]─[%f%F{162}%D{%H:%M-%d/%m}%f%F{blue}]─[%f%F{cyan}%d%f%F{blue}]%f"$'\n'"%F{blue}└╼%f%F{162}$USER%f%F{blue} => %f"

source /opt/dotfiles/prompt.sh

export PATH=~/.local/bin:/snap/bin:/usr/sandbox/:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/share/games:/usr/local/sbin:/usr/sbin:/sbin:$PATH

#nvm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm



function hex-encode()
{
  echo "$@" | xxd -p
}

function hex-decode()
{
  echo "$@" | xxd -p -r
}

function rot13()
{
  echo "$@" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
}
alias ls='ls -lh --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias cat='bat'

source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh


bindkey -M viins              '^I'         menu-complete
bindkey -M viins "$terminfo[kcbt]" reverse-menu-complete
bindkey -M viins  '^[[D' .backward-char  '^[OD' .backward-char
bindkey -M viins  '^[[C'  .forward-char  '^[OC'  .forward-char
# bindkey -M viins             '^I' menu-select
bindkey "$terminfo[kcbt]" menu-select

if [[ "$EUID" -eq 0 ]]; then
	export DOCKER_HOST=unix:///run/user/1001/docker.sock
else
	export DOCKER_HOST=unix:///var/run/docker.sock
fi


export PATH=/home/arch_alex/c++/v8:$PATH

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt appendhistory

    
  

echo -en "\e]2;Terminal\a"
preexec () { print -Pn "\e]0;$1 - Terminal\a" }


alias redis(){
  docker run --rm -d -p 6379:6379 redis:latest
}

alias nats-container(){ 
  docker run --rm -d -p 4222:4222 nats:latest
}


alias changeMac(){
  sudo ifconfig wlp0s20f3 down 
  sudo macchanger -A wlp0s20f3
  sudo ifconfig wlp0s20f3 up
}


[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true

# pnpm
export PNPM_HOME="/home/arch_dev/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

# bun completions
[ -s "/home/arch_dev/.bun/_bun" ] && source "/home/arch_dev/.bun/_bun"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[[ -r "/usr/share/z/z.sh" ]] && source /usr/share/z/z.sh

export AWA_ROOT_PATH=/home/adsoftware/project/awa


[ -f "/home/adsoftware/.ghcup/env" ] && . "/home/adsoftware/.ghcup/env" # ghcup-env
autoload -Uz compinit
autoload -U promptinit
compinit
export AWA_ROOT_PATH=/home/adsoftware/test-proj/main/awa
source /home/adsoftware/test-proj/main/awa/turbo-comp.sh
