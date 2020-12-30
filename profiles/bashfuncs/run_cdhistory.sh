export ccdhistoryfile="${HOME}/.cdhistory"

if [ ! -f $ccdhistoryfile ]; then
  touch $ccdhistoryfile
fi

cd () { #DEFN In place of regular cd, save current directory to history before changing
  cur=`pwd`
  builtin cd $@
  if [[ "$?" == "0" ]]; then
    MAXHISTORY=100
    histdata="`cat $ccdhistoryfile`\n$cur"
    echo -e "$histdata" | tail -$MAXHISTORY | grep -v "^$" > $ccdhistoryfile
  fi
}

cdl () { #DEFN List recent folders visited
  cat $ccdhistoryfile | sort | uniq
}

cdr () { #DEFN Go back a folder
  backup=`tail -1 $ccdhistoryfile`
  builtin cd $backup
  head -n -1 $ccdhistoryfile > ${ccdhistoryfile}.swp
  mv ${ccdhistoryfile}.swp $ccdhistoryfile
}

