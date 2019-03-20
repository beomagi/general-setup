yaml2json () { #DEFN takes a stdin stream and outputs 
  python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)'
}
