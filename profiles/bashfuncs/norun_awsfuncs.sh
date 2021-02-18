
awssetnonmanual () { #DEFN
  export AWS_DEFAULT_PROFILE="$1"
  export AWS_PROFILE="$1"
  echo $AWS_PROFILE > /dev/shm/AWS_PROFILE.txt
}


awsloginserver () { #DEFN login to a server by IP
  cloud-tool --profile $AWS_PROFILE ssh --private-ip "$1"
}

awsloginmanual () { #DEFN login to aws for cloudtool
  passwd=`cat ${HOME}/pass.txt`
  where=0
  if [[ "$1 $2" == *"emea"* ]]; then where=1; REGION="eu-west-1"; fi
  if [[ "$1 $2" == *"amer"* ]]; then where=1; REGION="us-east-1"; fi
  if [[ "$1 $2" == *"apac"* ]]; then where=1; REGION="ap-southeast-2"; fi
  if [[ "$1 $2" == *"sing"* ]]; then where=1; REGION="ap-southeast-1"; fi
  if [ $where -eq 0 ]; then
    echo "say emea, amer, apac, sing... I've no idea where to connect to"
    return 1
  fi
  export AWS_DEFAULT_REGION=$REGION
  unset AWS_PROFILE
  unset AWS_DEFAULT_PROFILE
  cloud-tool --region "$REGION" login --username "mgmt\m0094748" --password "$passwd" | tee /dev/shm/ctlogin.txt
  sleep 0.1
  profileset=`cat /dev/shm/ctlogin.txt | grep "To use this cred" | sed 's_.*aws --profile __' | sed 's_ .*__'`
  echo "Set profile to $profileset. Region is $AWS_DEFAULT_REGION"
  awssetnonmanual $profileset
}

awslogineapnonprod () {
   echo 5 | awsloginmanual $1
   awssetnonmanual "`cat /dev/shm/AWS_PROFILE.txt`"
}

awslogineapprod () {
  echo 14 | awsloginmanual $1
   awssetnonmanual "`cat /dev/shm/AWS_PROFILE.txt`"
}
awslogindataminernonprod () {
  echo 33 | awsloginmanual $1
   awssetnonmanual "`cat /dev/shm/AWS_PROFILE.txt`"
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
    spc="                                                                              "
    out=`echo "${NME}${spc}" | cut -c1-42`
    out=`echo "${out}${IP}${spc}" | cut -c1-65`
    out=`echo "${out}${AMI}${spc}" | cut -c1-95`
    out=`echo "${out}${LT}${spc}" | cut -c1-125`
    out=`echo "${out}${IID}${spc}" | cut -c1-150`
    out=`echo "${out}${TYP}"`
    echo "$out"
  done | sort
}

awslistservers () { #DEFN list of EAP servers
  echo "Region: $REGION"
  aws ec2 describe-instances --filters Name=tag:tr:application-asset-insight-id,Values=204821 > /dev/shm/tmpserverlist.txt
  awslistserverscache
}

awslistserversall () { #DEFN list of EAP servers
  echo "Region: $REGION"
  aws ec2 describe-instances > /dev/shm/tmpserverlist.txt
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

awsrdp2id(){
    awstunnel2id $1
    sleep 1
    remmina -c /home/jumper/lt.remmina
}

awsalarms(){
(
    for leregions in us-east-1 eu-west-1 ap-southeast-1; do
        aws cloudwatch describe-alarms --region $leregions --alarm-name-prefix eap | jq -c ".[][]|({name: .AlarmName, state: .StateValue})" | grep '"ALARM"' \
        > /dev/shm/tmpcwalarms_$leregions & 
    done 
    wait
    for leregions in us-east-1 eu-west-1 ap-southeast-1; do
	echo $leregions
	cat /dev/shm/tmpcwalarms_$leregions
    done
)
}
