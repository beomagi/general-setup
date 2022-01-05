yaml2json () { #DEFN takes a stdin stream and outputs 
  python3 -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)'
}


cfgcompv() { #DEFN takes 2 config files, gets .versions and compares them
  file1=$1
  file2=$2
  key=".versions"
  v1="`cat $file1 | jq "$key" --sort-keys`"
  v2="`cat $file2 | jq "$key" --sort-keys`"
  diff <(echo "$v1") <(echo "$v2")
}
