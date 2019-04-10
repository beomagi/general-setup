
setnonprod () { #DEFN
  export AWS_DEFAULT_PROFILE="tr-central-preprod"
  export AWS_PROFILE="tr-central-preprod"
  echo $AWS_PROFILE > ~/params/AWS_PROFILE.txt
}

setprod () { #DEFN
  export AWS_DEFAULT_PROFILE="tr-central-prod"
  export AWS_PROFILE="tr-central-prod"
  echo $AWS_PROFILE > ~/params/AWS_PROFILE.txt
}

awsloginserver () { #DEFN login to a server by IP
  cloud-tool --profile $AWS_PROFILE ssh --private-ip "$1"
}

awslogin () { #DEFN login to aws for cloudtool
  passwd=`cat ${HOME}/pass.txt`
  where=0
  if [[ "$1 $2" == *"emea"* ]]; then where=1; export REGION="eu-west-1"; echo $REGION > ~/params/region.txt ; fi
  if [[ "$1 $2" == *"amer"* ]]; then where=1; export REGION="us-east-1"; echo $REGION > ~/params/region.txt ; fi
  if [[ "$1 $2" == *"apac"* ]]; then where=1; export REGION="ap-southeast-2"; echo $REGION > ~/params/region.txt ; fi
  if [ $where -eq 0 ]; then
    echo "say emea, amer, apac... I've no idea where to connect to"
    return 1
  fi
  trigger=0
  if [[ "$1 $2" == *"nonprod"* ]] || [[ "$1 $2" == *"preprod"* ]]; then 
    setnonprod; 
    trigger=3 #this value for NONPROD role selection
  else
    if [[ "$1 $2" == *"prod"* ]]; then 
      setprod;
      trigger=8 #this value for PROD role selection
    fi
  fi
  if [ $trigger -eq 0 ]; then
    echo "say prod, nonprod, preprod... I've no idea wtf you want :P"
    return 1
  fi
  echo "$trigger" | cloud-tool --region "$REGION" login --username "mgmt\m0094748" --password "$passwd"
}

awspass () { #DEFN Show current vault pass
  cat ~/pass.txt
}


awslistserverscache () { #DEFN use previously cached server list
  cat /dev/shm/tmpserverlist.txt | jq ".Reservations[].Instances[]" | jq "." -c | while read line; do
    LT=`echo $line | jq -r ".LaunchTime"`
    IP=`echo $line | jq -r ".PrivateIpAddress"`
    AMI=`echo $line | jq -r ".ImageId"`
    TYP=`echo $line | jq -r ".InstanceType"`
    NME=`echo $line | jq ".Tags[]" -c | grep '"Key":"Name"' | jq ".Value" -r`
    spc="............................................................................................."
    out=`echo "${NME}${spc}" | cut -c1-40`
    out=`echo "${out}${IP}${spc}" | cut -c1-58`
    out=`echo "${out}${AMI}${spc}" | cut -c1-83`
    out=`echo "${out}${LT}${spc}" | cut -c1-111`
    out=`echo "${out}${TYP}"`
    echo "$out"
  done | sort
}

awslistservers () { #DEFN list of EAP servers
  echo "Region: $REGION"
  aws ec2 describe-instances --filters Name=tag:tr:project-name,Values=EAP > /dev/shm/tmpserverlist.txt
  awslistserverscache
}

