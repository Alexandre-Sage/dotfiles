autoload -Uz vcs_info
precmd() { 
    vcs_info 
}

# Configure vcs_info
zstyle ':vcs_info:git:*' formats '%F{39}on %b%f'
zstyle ':vcs_info:git:*' actionformats '%F{39}on %b%f %F{red}(%a)%f'
zstyle ':vcs_info:*' enable git

setopt PROMPT_SUBST
PS1="%F{34}┌[%F{40}%D{%Y-%m-%d} %F{46}%D{%H:%M}%f%F{154}]-%F{39}[%n%F{45}@%F{51}%m]%f-[%F{165}%d]"$'\n'"└╼ \${vcs_info_msg_0_} %F{240}➡️ %f"
