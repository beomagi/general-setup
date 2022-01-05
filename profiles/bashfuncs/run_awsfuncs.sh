export tmpfs=/dev/shm
if [ ! -e "$tmpfs" ]; then export tmpfs=/tmp; fi

export cloudtoolopts=/home/jumper/cloudtool-opts.txt
export ct_eappreprod=`cat $cloudtoolopts  | grep 060725138335 | grep "204821-PowerUser " | tr -d '[]:' | awk '{print $1}'`
export ct_eapprod=`cat $cloudtoolopts  | grep 304853478528 | grep "204821-PowerUser " | tr -d '[]:' | awk '{print $1}'`
export ct_dataminer=`cat $cloudtoolopts  | grep 910031690486 | grep "a205561-PowerUser2 "  | tr -d '[]:' | awk '{print $1}'`



awssetnonmanual () { #DEFN set AWS_DEFAULT_PROFILE env variable to passed string
  export AWS_DEFAULT_PROFILE="$1"
  export AWS_PROFILE="$1"
  echo $AWS_PROFILE > ${tmpfs}/AWS_PROFILE.txt
}


awsloginserver () { #DEFN login to a server by IP
  cloud-tool --profile $AWS_PROFILE ssh --private-ip "$1"
}

awssession () { #DEFN login to a server using AWS session manager
  aws ssm start-session --target $1
}

awsloginmanual () { #DEFN login to aws for cloudtool
  passwd=`cat ${HOME}/pass.txt`
  where=0
  if [[ "$1 $2" == *"eu-west-1"* ]]; then where=1; REGION="eu-west-1"; fi
  if [[ "$1 $2" == *"emea"* ]]; then where=1; REGION="eu-west-1"; fi
  if [[ "$1 $2" == *"us-east-1"* ]]; then where=1; REGION="us-east-1"; fi
  if [[ "$1 $2" == *"amer"* ]]; then where=1; REGION="us-east-1"; fi
  if [[ "$1 $2" == *"apac"* ]]; then where=1; REGION="ap-southeast-1"; fi
  if [[ "$1 $2" == *"ap-southeast-1"* ]]; then where=1; REGION="ap-southeast-1"; fi
  if [[ "$1 $2" == *"sing"* ]]; then where=1; REGION="ap-southeast-1"; fi
  if [ $where -eq 0 ]; then
    echo "say emea, amer, apac, sing... I've no idea where to connect to"
    return 1
  fi
  export AWS_DEFAULT_REGION=$REGION
  unset AWS_PROFILE
  unset AWS_DEFAULT_PROFILE
  cloud-tool --region "$AWS_DEFAULT_REGION" login --username "mgmt\m0094748" --password "$passwd" | tee ${tmpfs}/ctlogin.txt
  sleep 0.1
  profileset=`cat ${tmpfs}/ctlogin.txt | grep "To use this cred" | sed 's_.*aws --profile __' | sed 's_ .*__'`
  echo "Set profile to $profileset. Region is $AWS_DEFAULT_REGION"
  awssetnonmanual $profileset
}

awsregion () { #DEFN set aws_default_region value
  REGION="$1"
  if [[ "$1 $2" == *"emea"* ]]; then where=1; REGION="eu-west-1"; fi
  if [[ "$1 $2" == *"amer"* ]]; then where=1; REGION="us-east-1"; fi
  if [[ "$1 $2" == *"apac"* ]]; then where=1; REGION="ap-southeast-2"; fi
  if [[ "$1 $2" == *"sing"* ]]; then where=1; REGION="ap-southeast-1"; fi
  export AWS_DEFAULT_REGION=$REGION
}

awsamiage () { #DEFN get the creation date of an ami image
  aws ec2 describe-images --image-ids $1  2>/dev/null | jq -r ".Images[].CreationDate" 2>/dev/null
}

awsamiagec () { #DEFN get the creation date and cache the result. Pull from cache if available
  cachecheck=`grep "\"$1\"" /${HOME}/amicache 2>/dev/null`
  if [[ "$cachecheck" == "" ]]; then 
    amidate=`awsamiage $1`
    if [[ "$amidate" > "" ]]; then
      echo $amidate
      echo "\"$1\" $amidate" >> /${HOME}/amicache
    fi
  else
    echo "$cachecheck" | awk '{print $2}'
  fi

}


#note options here are piped into login, so login subprocess variables won't hold and must be set again after
awslogineapnonprod () {
   echo $ct_eappreprod | awsloginmanual $1
   awssetnonmanual "`cat ${tmpfs}/AWS_PROFILE.txt`"
   awsregion $1
}

awslogineapprod () {
  echo $ct_eapprod | awsloginmanual $1
   awssetnonmanual "`cat ${tmpfs}/AWS_PROFILE.txt`"
   awsregion $1
}

awslogindataminer () {
  echo $ct_dataminer | awsloginmanual $1
   awssetnonmanual "`cat ${tmpfs}/AWS_PROFILE.txt`"
   awsregion $1
}


awspass () { #DEFN Show current vault pass
  cat ~/pass.txt
}


awsecsinfo () { #DEFN list of EAP servers
  echo "Region: $AWS_DEFAULT_REGION"
  ${HOME}/bashfuncs/ecshealth.py $@
}

awslistserversall () { #DEFN list of EAP servers
  echo "Region: $AWS_DEFAULT_REGION"
  ${HOME}/bashfuncs/ec2lister.py $@
}

awsvalidatetemplate () { #DEFN validata template file
  aws cloudformation validate-template --template-body file://$1
}

awstunnel2id (){ #DEFN setup a cloud-tool bastion tunnnel for RDP. Pass instance-ID [alternalte port]
    insid=$1
    portalternate=$2
    $2 && portalternate=3399
    idinfo=`aws ec2 describe-instances --instance-ids $insid`
    idip=`echo "$idinfo" | jq -r ".Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddress"`
    keyname=`aws ec2 describe-instances --instance-id $insid | grep KeyName | awk '{print $2}' | tr -d '",'`
    aws ec2 get-password-data --instance-id  $insid --priv-launch-key ~/gits/eap_secure/ec2_ssh_keys/${keyname}.pem | jq -r ".PasswordData"
    cloud-tool --region "$AWS_DEFAULT_REGION" --profile $AWS_PROFILE ssh-tunnel -b $idip -j -q 3389 -r $portalternate
}

awsrdp2idi (){ #DEFN setup a tunnel to an instance it, and launch remmina remote desktop client
    awstunnel2id $1
    sleep 1
    remmina -c /home/jumper/lt.remmina
}

awsalarms (){ #DEFN Get all AWS alarms that match certain strings and output them for several regions
(
    for leregions in us-east-1 eu-west-1 ap-southeast-1; do
        alfile=${tmpfs}/tmpcwalarms_$leregions
	rm $alfile 2>/dev/null
        aws cloudwatch describe-alarms --region $leregions --alarm-name-prefix eap | jq -c ".[][]|({name: .AlarmName, state: .StateValue})" | grep '"ALARM"' >> $alfile & 
        aws cloudwatch describe-alarms --region $leregions --alarm-name-prefix a204821 | jq -c ".[][]|({name: .AlarmName, state: .StateValue})" | grep '"ALARM"' >> $alfile & 
    done 
    wait
    for leregions in us-east-1 eu-west-1 ap-southeast-1; do
	echo $leregions
	cat ${tmpfs}/tmpcwalarms_$leregions
    done
)
}
