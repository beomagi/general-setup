

ftrst='\e[0m'
cbg () { echo "\e[48;5;${1}m"; }
cfg () { echo "\e[38;5;${1}m"; }

awscred () { #DEFN Show unexpired and switch to different AWS profiles
  credscript="${HOME}/bashfuncs/credpicker.py"
  picks=`$credscript`
  if [ ! -z "AWS_PROFILE" ]; then echo "Current - $AWS_PROFILE"; fi
  echo "$picks"
  if [ ! -z "$1" ]; then
    pickprof=`echo "$picks" | grep " $1 " | awk '{print $2}'`
    if [ ! -z "$pickprof" ]; then
      echo "Switching to $pickprof"
      export AWS_PROFILE="$pickprof"
      export AWS_DEFAULT_PROFILE="$pickprof"
    fi
  fi 
}

