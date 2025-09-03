aws_get_conf_data () { #DEFN get subnet, vpc and ami info for basic setups 

  aws sts get-caller-identity | jq

  echo -e "\nPrivate Subnets"
  subsPriv=`aws ec2 describe-subnets | jq -c ".Subnets[]" | grep "tr-vpc-1.private"`
  while read -r asub; do
    subid=`echo "$asub" | jq -r ".SubnetId"`
    subnm=`echo "$asub" | jq -c ".Tags[]" | grep '"Key":"Name"' | jq -r ".Value"`
    echo "$subid,$subnm"
  done <<< "$subsPriv" | column -t -s ','

  echo -e "\nPublic Subnets"
  subsPriv=`aws ec2 describe-subnets | jq -c ".Subnets[]" | grep "tr-vpc-1.public"`
  while read -r asub; do
    subid=`echo "$asub" | jq -r ".SubnetId"`
    subnm=`echo "$asub" | jq -c ".Tags[]" | grep '"Key":"Name"' | jq -r ".Value"`
    echo "$subid,$subnm"
  done <<< "$subsPriv" | column -t -s ','

  echo -e -n "\nGathering AMI Info "
  allamissm=`aws ssm get-parameters-by-path --path "/a205257/cicd/" | jq -r   ".Parameters[].Name" | grep -ie windows -ie linux | sort`
  allamifmt=""
  while true; do
    echo -n " ."
    currten=`echo "$allamissm" | head -n 10`
    if [[ "$currten" = "" ]]; then break
    fi
    allamissm=`echo "$allamissm" | tail -n +10`
    tenraw=`aws ssm get-parameters --names $currten`
    tentrm=`echo "$tenraw" | jq -r '.Parameters[]|(.Name +","+ .Value +","+ .LastModifiedDate)'`
    allamifmt+="\n$tentrm"
  done 
  echo ""
  echo -e "$allamifmt" | column -t -s ','
}
