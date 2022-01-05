displayset () { #DEFN sets display to output to local client if connecting here via ssh
  #hostip=`pinky -f | grep pts | grep -v tmux | awk '{print $NF}'`
  #export DISPLAY=${hostip}:0
  export DISPLAY=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0
  export LIBGL_ALWAYS_INDIRECT=1

}
