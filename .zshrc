setxkbmap fr 
fastfetch
autoload -U promptinit
source ~/.local/.ads-env
autoload -Uz compinit
compinit
export EDITOR=nvim
PROMPT="%F{blue}┌[%f%F{cyan}%m%f%F{blue}]─[%f%F{162}%D{%H:%M-%d/%m}%f%F{blue}]─[%f%F{cyan}%d%f%F{blue}]%f"$'\n'"%F{blue}└╼%f%F{162}$USER%f%F{blue} => %f"

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
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh
bindkey -M menuselect              '^I'         menu-complete
bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete
bindkey -M menuselect  '^[[D' .backward-char  '^[OD' .backward-char
bindkey -M menuselect  '^[[C'  .forward-char  '^[OC'  .forward-char
bindkey              '^I' menu-select
bindkey "$terminfo[kcbt]" menu-select

export DOCKER_HOST=unix:///run/user/1001/docker.sock
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
mkdirFile(){
  mkdir -p "$(dirname "$1")" && touch "$1";
}

    
  

echo -en "\e]2;Terminal\a"
preexec () { print -Pn "\e]0;$1 - Terminal\a" }


alias airPackRedis(){
  sudo docker run --rm -d -p 6379:6379 redis
}

alias changeMac(){
  sudo ifconfig wlp0s20f3 down 
  sudo macchanger -A wlp0s20f3
  sudo ifconfig wlp0s20f3 up
}



alias fire(){
  firefox &> /dev/null &
}

alias cumTeam(){
  chromium "https://teams.microsoft.com/_?lm=deeplink&lmsrc=NeutralHomePageWeb&cmpid=WebSignIn&culture=fr-fr&country=fr#/conversations/General?threadId=19:17c4925a8ce54a1bba0b4e583e276dff@thread.tacv2&ctx=channel" &> /dev/null &
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
# source /home/adsoftware/workspace/dadbod-connect.comp.sh


[ -f "/home/adsoftware/.ghcup/env" ] && . "/home/adsoftware/.ghcup/env" # ghcup-env
