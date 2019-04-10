

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
  colsiz0=`cfg 150`
  namesizetable=""
  while read fentry; do
    fspace=`timeout -k 0.1 0.1 du -h "$fentry" 2>/dev/null | tail -1 | awk '{print $1}'` #get total
    namesizetable="${namesizetable}\n${fspace} ${fentry}"
  done < <(echo "$flist")
  namesizetable=`echo -e "$namesizetable" | sort -hr`
  echo "get space, mount and tabulate"
  echo "$namesizetable" | while read line; do
    fspace=`echo "$line"|awk '{print $1}'`
    fentry=`echo "$line"|cut -d ' ' -f2-99`
    padding='......................................................................'
    colsize="$colsiz0"
    if [[ "$fspace" == *"K"* ]]; then colsize="$colsizK"; fi
    if [[ "$fspace" == *"M"* ]]; then colsize="$colsizM"; fi
    if [[ "$fspace" == *"G"* ]]; then colsize="$colsizG"; fi
    if [[ "$fspace" == *"T"* ]]; then colsize="$colsizT"; fi
    str1=`echo "${colfile}${fentry}${colpadd}${padding}" | cut -c1-80`
    spaceused=`df -h --output=used,size "$fentry"| tail -1 | awk '{print $1 "/" $2}'`
    mountpoint=`df -h --output=target "$fentry"| tail -1`
    str2="${str1}${colsize}${fspace}${colpadd}${padding}"
    str3=`echo "$str2" | cut -c1-115`
    str4="${str3}${colsize}${spaceused}${colpadd}${padding}"
    str5=`echo "$str4" | cut -c1-155`
    str6="${str5}${colfile}${mountpoint}"
    echo -e "${str6}${ftrst}"
  done
}

