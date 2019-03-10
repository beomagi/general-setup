displayset () { #DEFN sets display to output to local client if connecting here via ssh
  hostip=`pinky -f | grep pts | grep -v tmux | awk '{print $NF}'`
  export DISPLAY=${hostip}:0
}
