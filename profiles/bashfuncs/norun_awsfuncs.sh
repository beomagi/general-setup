
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
  if [[ "$1 $2" == *"sing"* ]]; then where=1; export REGION="ap-southeast-1"; echo $REGION > ~/params/region.txt ; fi
  if [ $where -eq 0 ]; then
    echo "say emea, amer, apac, sing... I've no idea where to connect to"
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
    LT=`echo $line | jq -r ".LaunchTime"| sed 's_.000Z__g'`
    IP=`echo $line | jq -r ".PrivateIpAddress"`
    AMI=`echo $line | jq -r ".ImageId"`
    TYP=`echo $line | jq -r ".InstanceType"`
    IID=`echo $line | jq -r ".InstanceId"`
    NME=`echo $line | jq ".Tags[]" -c | grep '"Key":"Name"' | jq ".Value" -r`
    spc="............................................................................................."
    out=`echo "${NME}${spc}" | cut -c1-38`
    out=`echo "${out}${IP}${spc}" | cut -c1-55`
    out=`echo "${out}${AMI}${spc}" | cut -c1-78`
    out=`echo "${out}${LT}${spc}" | cut -c1-99`
    out=`echo "${out}${IID}${spc}" | cut -c1-120`
    out=`echo "${out}${TYP}"`
    echo "$out"
  done | sort
}

awslistservers () { #DEFN list of EAP servers
  echo "Region: $REGION"
  aws ec2 describe-instances --filters Name=tag:tr:project-name,Values=EAP > /dev/shm/tmpserverlist.txt
  awslistserverscache
}

awsvalidatetemplate () { #DEFN validata template file
  aws cloudformation validate-template --template-body file://$1
}


awstunnel2id(){ #DEFN setup a cloud-tool bastion tunnnel for RDP. Pass instance-ID [alternalte port]
    insid=$1
    portalternate=$2
    $2 && portalternate=3399
    idinfo=`aws ec2 describe-instances --instance-ids $insid`
    idip=`echo "$idinfo" | jq -r ".Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddress"`
    keyname=`aws ec2 describe-instances --instance-id $insid | grep KeyName | awk '{print $2}' | tr -d '",'`
    aws ec2 get-password-data --instance-id  $insid --priv-launch-key ~/gits/eap_secure/ec2_ssh_keys/${keyname}.pem | jq -r ".PasswordData"
    cloud-tool --region "$REGION" --profile $AWS_PROFILE ssh-tunnel -b $idip -j -q 3389 -r $portalternate
}

awsalarms(){
    for leregions in us-east-1 eu-west-1 ap-southeast-1 ap-southeast-2; do
        echo "$leregions"
        aws cloudwatch describe-alarms --region $leregions --alarm-name-prefix eap | jq -c ".[][]|({name: .AlarmName, state: .StateValue})" | grep '"ALARM"'
    done
}
