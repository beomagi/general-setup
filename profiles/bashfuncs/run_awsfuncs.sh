export tmpfs=/dev/shm
if [ ! -e "$tmpfs" ]; then export tmpfs=/tmp; fi

export cloudtoolopts=/home/jumper/cloudtool-opts.txt
#EAP accounts
export ct_eappreprod=`cat $cloudtoolopts  | grep 060725138335 | grep "204821-PowerUser " | tr -d '[]:' | awk '{print $1}'`
export    ct_eapprod=`cat $cloudtoolopts  | grep 304853478528 | grep "204821-PowerUser " | tr -d '[]:' | awk '{print $1}'`
#Dataminer
export  ct_dataminer=`cat $cloudtoolopts  | grep 910031690486 | grep "a205561-PowerUser2"  | tr -d '[]:' | awk '{print $1}'`
#NewsRoom
export ct_nr_cicdprod_202333=`cat $cloudtoolopts  | grep 556060016006 | grep "a202333-PowerUser2" | tr -d '[]:' | awk '{print $1}'`
export  ct_nr_preprod_202333=`cat $cloudtoolopts  | grep 426942580712 | grep "a202333-PowerUser2" | tr -d '[]:' | awk '{print $1}'`
export     ct_nr_prod_202333=`cat $cloudtoolopts  | grep 041916277582 | grep "a202333-PowerUser2" | tr -d '[]:' | awk '{print $1}'`

export ct_nr_cicdprod_202909=`cat $cloudtoolopts  | grep 556060016006 | grep "a202909-PowerUser2" | tr -d '[]:' | awk '{print $1}'`
export  ct_nr_preprod_202909=`cat $cloudtoolopts  | grep 426942580712 | grep "a202909-PowerUser2" | tr -d '[]:' | awk '{print $1}'`
export     ct_nr_prod_202909=`cat $cloudtoolopts  | grep 041916277582 | grep "a202909-PowerUser2" | tr -d '[]:' | awk '{print $1}'`

export ct_nr_cicdprod_208210=`cat $cloudtoolopts  | grep 556060016006 | grep "a208210-PowerUser2" | tr -d '[]:' | awk '{print $1}'`
export  ct_nr_preprod_208210=`cat $cloudtoolopts  | grep 426942580712 | grep "a208210-PowerUser2" | tr -d '[]:' | awk '{print $1}'`
export     ct_nr_prod_208210=`cat $cloudtoolopts  | grep 041916277582 | grep "a208210-PowerUser2" | tr -d '[]:' | awk '{print $1}'`

export ct_nr_cicdprod_208193_NFS=`cat $cloudtoolopts  | grep 556060016006 | grep "a208193-PowerUser2" | tr -d '[]:' | awk '{print $1}'`
export  ct_nr_preprod_208193_NFS=`cat $cloudtoolopts  | grep 426942580712 | grep "a208193-PowerUser2" | tr -d '[]:' | awk '{print $1}'`
export     ct_nr_prod_208193_NFS=`cat $cloudtoolopts  | grep 041916277582 | grep "a208193-PowerUser2" | tr -d '[]:' | awk '{print $1}'`

export ct_nr_cicdprod_208187_nmc=`cat $cloudtoolopts  | grep 556060016006 | grep "a208187-PowerUser2" | tr -d '[]:' | awk '{print $1}'`
export  ct_nr_preprod_208187_nmc=`cat $cloudtoolopts  | grep 426942580712 | grep "a208187-PowerUser2" | tr -d '[]:' | awk '{print $1}'`
export     ct_nr_prod_208187_nmc=`cat $cloudtoolopts  | grep 041916277582 | grep "a208187-PowerUser2" | tr -d '[]:' | awk '{print $1}'`

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

awsec2remote () { #DEFN run on instance param1 command param2
  insec2=$1
  runcommand="$2"
  awsshellscript="AWS-RunShellScript"
  for paramidx in "$@" ; do
    if [[ "$paramidx" == "--windows" ]] ; then
      awsshellscript="AWS-RunPowerShellScript"
    fi
  done
  #Send command to isntance
  runcommand_escaped=$(printf '%s\n' "$runcommand" | sed 's/"/\\"/g')  # Escape double quotes
  #hook=$(aws ssm send-command --instance-ids "$insec2" --document-name "$awsshellscript" --comment "IP config" --parameters commands="$runcommand" --output json)
  hook=$(aws ssm send-command \
    --instance-ids "$insec2" \
    --document-name "$awsshellscript" \
    --comment "IP config" \
    --parameters "commands=[\"${runcommand_escaped}\"]" \
    --output json)
  if [ -z "$hook" ]; then
    echo "Unable to send command to $insec2"
    return
  fi
  #Poll for Success/Fail
  cmdid=$(echo "$hook" | jq -r ".Command.CommandId")
  while [[ "$status" != "Success" && "$status" != "Failed" ]]; do
    sleep 1
    output=`aws ssm get-command-invocation --command-id $cmdid --instance-id $insec2`
    status=`echo "$output" | jq -r ".Status"`
    echo "`date` $status"
  done
  #Output will be written to until execution end, poll till no change.
  oldsum="+"
  while true; do
    output=`aws ssm get-command-invocation --command-id $cmdid --instance-id $insec2`
    currentoutputsum=$(echo -e "`echo \"$output\" | jq -r ".StandardOutputContent"`" | md5sum | awk '{print $1}')
    currenterrorssum=$(echo -e "`echo \"$output\" | jq -r ".StandardErrorContent"`" | md5sum | awk '{print $1}')
    cursum="$currentoutputsum $currenterrorssum"
    if [[ "$cursum" == "$oldsum" ]]; then
      break
    fi
    oldsum="$cursum"
    sleep 2
  done
  #Output stdout and stderr
  echo "###---Output---###"
  echo -e "`echo \"$output\" | jq -r ".StandardOutputContent"`"
  echo "###---Errors---###"
  echo -e "`echo \"$output\" | jq -r ".StandardErrorContent"`"
}

awsloginmanual () { #DEFN login to aws for cloudtool
  # $1 region
  # $2 option by number
  passwd=`cat ${HOME}/pass.txt`
  where=0
  awsregion $1
  err=$?
  if [ "$err" -gt 0 ]; then
    return 1
  fi
  unset AWS_PROFILE
  unset AWS_DEFAULT_PROFILE
  profileopt=`cat ~/cloudtool-opts.txt | grep "\[ *$2\]"| awk -F ':' '{print $2}'| awk '{print $1}'`
  usrroleopt=`cat ~/cloudtool-opts.txt | grep "\[ *$2\]"| awk -F ':' '{print $3}'| awk '{print $1}'`
  usracctopt=`cat ~/cloudtool-opts.txt | grep "\[ *$2\]"| awk -F ':' '{print $2}'| awk '{print $2}'|tr -d '()'`
  if [[ "$profileopt" == "" ]]; then profileopt="default"; fi
  echo "use profile $profileopt"
  echo "cloud-tool -r \"$AWS_DEFAULT_REGION\" -p $profileopt login --username \"mgmt\m0094748\" --password \"\$passwd\" -r \"$usrroleopt\" -a \"$usracctopt\"" 
  cloud-tool -r "$AWS_DEFAULT_REGION" -p $profileopt login --username "mgmt\m0094748" --password "$passwd" -r "$usrroleopt" -a "$usracctopt" 
  sleep 0.1
  echo "Set profile to $profileopt. Region is $AWS_DEFAULT_REGION"
  awssetnonmanual $profileopt
}

awsregion () { #DEFN set aws_default_region value
  REGION="$1"
  if [[ "$1" == *"emea"* ]]; then REGION="eu-west-1"; fi
  if [[ "$1" == *"amer"* ]]; then REGION="us-east-1"; fi
  if [[ "$1" == *"apac"* ]]; then REGION="ap-southeast-2"; fi
  if [[ "$1" == *"sing"* ]]; then REGION="ap-southeast-1"; fi
  if [ -z "$REGION" ]; then
    echo "pass region or emea, amer, apac, sing... I've no idea where to connect to"
    return 1
  fi
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


awsgetopts () { #FEDN recreate the options file
  awsloginmanual emea 0 | grep ']: ' > ${HOME}/cloudtool-opts.txt
}

#note options here are piped into login, so login subprocess variables won't hold and must be set again after
awslogineapnonprod () {
   awsloginmanual $1 $ct_eappreprod
}

awslogineapprod () {
  awsloginmanual $1 $ct_eapprod
}

awslogindataminer () {
   awsloginmanual $1 $ct_dataminer
}


awspass () { #DEFN Show current vault pass
  cat ~/pass.txt
}

awspclip () { #DEFN Put password in clipboard
  cat ~/pass.txt | clip.exe
}

awsecsinfo () { #DEFN list of EAP clusters matching given parameters
  ${HOME}/bashfuncs/ecshealth.py $@
}

awsecsec2stat () { #DEFN list instances registered to the cluster and determine if the agent is disconnected
  CLUSTERSUBSTR="$1"
  while read CLUSTER_NAME; do
    conec2s=`aws ecs list-container-instances --cluster $CLUSTER_NAME | jq -r ".containerInstanceArns[]"`
    if [ -z "$conec2s" ]; then
      echo -e "$CLUSTER_NAME\nNo-instances ***"
      continue
    fi
    allserverstats=`aws ecs describe-container-instances --cluster "$CLUSTER_NAME" --container-instances $conec2s`
    discoec2s=`echo $allserverstats | jq '.containerInstances[]'| jq -c '{ ec2id:.ec2InstanceId, status: .status, agentConnected: .agentConnected }' | grep false`
    discoec2list=`echo "$discoec2s" | jq -r ".ec2id"`
    echo $discoec2list | grep "i-" || echo "no disconnections"
  done <<< `aws ecs list-clusters | jq -r ".clusterArns[]" | grep $CLUSTERSUBSTR`
}

awsecsmain() { #DEFN 
  echo "gathering data..."
  echo ""
  (awsecsinfo -region=us-east-1 governance services-windows wwworker a204821-turbo > $tmpfs/ecsus.txt &
  awsecsinfo -region=eu-west-1 governance services-windows wwworker a204821-turbo > $tmpfs/ecsem.txt &
  awsecsinfo -region=ap-southeast-1 governance services-windows wwworker a204821-turbo > $tmpfs/ecssi.txt &
  wait)
  ${HOME}/bashfuncs/columize.py $tmpfs/ecsus.txt $tmpfs/ecsem.txt $tmpfs/ecssi.txt
}

awswhatsup() { #DEFN alarm and ecs overview of EAP
  awsalarms
  echo ""
  awsecsmain
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
    echo "cloud-tool --region \"$AWS_DEFAULT_REGION\" --profile $AWS_PROFILE ssh-tunnel -b $idip -j -q 3389 -r $portalternate"
    cloud-tool --region "$AWS_DEFAULT_REGION" --profile $AWS_PROFILE ssh-tunnel -b $idip -j -q 3389 -r $portalternate
}

awspf2id (){ #DEFN port forwarding
    insid=$1
	portin=$2
    portalternate=$3
    idinfo=`aws ec2 describe-instances --instance-ids $insid`
    idip=`echo "$idinfo" | jq -r ".Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddress"`
    keyname=`aws ec2 describe-instances --instance-id $insid | grep KeyName | awk '{print $2}' | tr -d '",'`
    aws ec2 get-password-data --instance-id  $insid --priv-launch-key ~/gits/eap_secure/ec2_ssh_keys/${keyname}.pem | jq -r ".PasswordData"
    cloud-tool --region "$AWS_DEFAULT_REGION" --profile $AWS_PROFILE ssh-tunnel -b $idip -j -q $portin -r $portalternate
}



awsrdp2idi (){ #DEFN setup a tunnel to an instance it, and launch remmina remote desktop client
    awstunnel2id $1
    sleep 1
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

alias ec2nuke="aws ec2 terminate-instances --instance-ids"
