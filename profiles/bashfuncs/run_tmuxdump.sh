
tmuxdump () { #DEFN dump the tmux buffer to filename param
  tmux capture-pane -pS -1000000 > "$1"
}


