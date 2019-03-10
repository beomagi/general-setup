

ftrst='\e[0m'
cbg () { echo "\e[48;5;${1}m"; }
cfg () { echo "\e[38;5;${1}m"; }

spacechk () { #DEFN show space at the current or specified location
  loc='.'
  if [ ! $# -eq 0 ]; then
    loc=$1
  fi
  flist=`find "$loc" -maxdepth 1 -mindepth 1 2>/dev/null | sort` #get list of files/folders
  colfile=`cfg 45`
  colpadd=`cfg 59`
  colsizK=`cfg 112`
  colsizM=`cfg 220`
  colsizG=`cfg 197`
  colsizT=`cfg 196`
  namesizetable=$(echo "$flist" | while read fentry; do
    fspace=`du -h "$fentry" 2>/dev/null | tail -1 | awk '{print $1}'` #get total
    echo "$fspace $fentry"
  done|sort -hr)

  echo "$namesizetable" | while read line; do
    fspace=`echo "$line"|awk '{print $1}'`
    fentry=`echo "$line"|cut -d ' ' -f2-99`
    padding='......................................................................'
    colsize="$colsizT"
    if [[ "$fspace" == *"K"* ]]; then colsize="$colsizK"; fi
    if [[ "$fspace" == *"M"* ]]; then colsize="$colsizM"; fi
    if [[ "$fspace" == *"G"* ]]; then colsize="$colsizG"; fi
    str1=`echo "${colfile}${fentry}${colpadd}${padding}" | cut -c1-80`
    str2="${str1}${colsize}${fspace}"
    echo -e "${str2}${ftrst}"
  done
}

