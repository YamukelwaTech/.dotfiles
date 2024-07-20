# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Update PATH to include npm global binaries
export PATH="$PATH:$HOME/.npm-global/bin"

#aliases
alias g="git"
alias gs="git status"
alias ga="git add"
alias gd="git diff"
alias gc="git commit"
alias gcz="git cz"
alias gp="git pull"
alias gps="git push"
alias gl='git log --pretty=format:"%C(auto,blue)%>(12,trunc)%ad %C(auto,green)%<(15,trunc)%aN%C(auto,reset)%s%C(auto,red)% gD% D" --graph'
alias ls="eza --icons=always"

# Alias to open a file or directory in the home directory
openfl() {
  local target="$HOME/$1"
  if [ -e "$target" ]; then
    open "$target"
  else
    echo "File or directory '$1' not found in home directory."
  fi
}

# Alias to source a file in the home directory
sourcefl() {
  local file="$HOME/$1"
  if [[ -f "$file" ]]; then
    source "$file"
  else
    echo "File '$1' not found in home directory."
  fi
}

# Function to start a server on port 8082 after ensuring the port is free
startserver() {
  # Function to kill any process using a specified port
  function kill_port() {
    local port=$1
    local pids
    pids=$(lsof -ti :$port)
    if [[ -n "$pids" ]]; then
      echo "Killing processes using port $port: $pids"
      for pid in $pids; do
        echo "Killing process $pid"
        kill -9 $pid
        echo "Process $pid killed"
      done
    else
      echo "No process using port $port"
    fi
  }

  # Kill any process using port 8082
  kill_port 8082

  # Wait for the port to be freed
  while lsof -ti :8082; do
    echo "Waiting for port 8082 to be freed..."
    sleep 1
  done

  # Start your server with the 'hrs' command
  hrs &
  local server_pid=$!

  # Wait for the server to be ready
  while ! nc -z localhost 8082; do
    echo "Waiting for server to start..."
    sleep 1
  done

  # Open the localhost URL in the default web browser
  open http://localhost:8082

  echo "Server started with PID $server_pid and localhost opened in browser"
}

# Initialize zoxide prompt
eval "$(zoxide init zsh)"

# Initialize fnm prompt
eval "$(fnm env --use-on-cd)"

# Source zsh-autosuggestions and zsh-syntax-highlighting
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme

# Update PATH to include MySQL binaries and fnm
export PATH="/usr/local/mysql/bin:$PATH"
export PATH="$HOME/.fnm:$PATH"

# Source Powerlevel10k configuration if it exists
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# solves
# gitstatus_stop_p9k_:zle:41: No handler installed for fd 14
# gitstatus_stop_p9k_:49: failed to close file descriptor 14: bad file descriptor
unset ZSH_AUTOSUGGEST_USE_ASYNC

# remove login
touch ~/.hushlogin
