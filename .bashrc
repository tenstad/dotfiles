EDITOR=nano
PROJECT_DIR=~/coding

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &> /dev/null
yes | ~/.fzf/install &> /dev/null

alias p='find "$PROJECT_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | fzf --preview "ls -A $PROJECT_DIR/{}" | xargs -ri code "$PROJECT_DIR/{}"'

alias g='git'
for cmd in $(git ls | awk '{print $1}'); do alias "g${cmd}"="git ${cmd}"; done

alias be='"$EDITOR" ~/.bashrc'
alias bsrc='source ~/.bashrc'
alias bsync='cp "$PROJECT_DIR/dotfiles/.bashrc" ~/.bashrc && source ~/.bashrc'

alias n='cat ~/.notes'
alias ne='"$EDITOR" ~/.notes'

alias d='docker'
alias k='kubectl'
