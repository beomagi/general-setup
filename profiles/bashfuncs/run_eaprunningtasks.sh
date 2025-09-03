gettasks() { #DEFN takes region, create task_region.txt with running tasks
  regs=$1
  echo "#--REGION-- $regs" > /tmp/task_${regs}.txt
  CLUSTER_NAME=eap-prd-worker
  running_tasks=$(aws ecs list-tasks --region $regs --cluster $CLUSTER_NAME --desired-status RUNNING --query 'taskArns' --output text | tr "\t" "\n" | grep arn | sort | uniq)
  while [ -n "$running_tasks" ]; do
    firstgrp=`echo "$running_tasks" | tr "\t" "\n" | head -50`
    running_tasks=$(echo "$running_tasks" | tail +51)
    grouptasks=$(echo "$firstgrp" | tr "\n" " ")
    task_details=$(aws ecs describe-tasks --region $regs --cluster $CLUSTER_NAME --tasks $grouptasks)
	echo $task_details  | jq -r ".tasks[]|.containers[]|(.image +\",\"+ .lastStatus)" | sed 's_^.*\/__g' | sort | uniq | grep RUNNING  >> task_${regs}.txt
  done
}

eap_tasks() { #DEFN create txt files with lists of all running tasks
  for regs in us-east-1 eu-west-1 ap-southeast-1; do
    gettasks $regs &
    sleep 0.2
  done
  wait
  echo "done!"
}
