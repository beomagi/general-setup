eap_ec2stat() { #DEFN takes ec2-id, env, mins back and returns process statistics
    ec2id=$1 #required
    if [ -z "$ec2id" ]; then
        echo "usage: $0 <ec2-id:required> <env:required> <mins-back:optional>"
    fi
    env=$2 #required, if not prd, stg, qa or dev return error
    if [ "$env" != "prd" ] && [ "$env" != "stg" ] && [ "$env" != "qa" ] && [ "$env" != "dev" ]; then
        echo "Invalid environment, must be prd, stg, qa or dev"
        return 1
    fi
    mins=$3 #optional, default 15
    if [ -z "$mins" ]; then
        mins=15
    fi
    querydata=`aws logs start-query \
    --log-group-name "/eap/${env}/application_checks" \
    --start-time $(date -d "-${mins} min" +%s) \
    --end-time $(date +%s) \
    --query-string "fields @timestamp, @logStream, @message | filter @logStream like /${ec2id}/ | sort @timestamp desc | limit 1"`
    queryid=`echo $querydata | jq -r ".queryId"`
    echo "Log Insights QueryID: $queryid"
    echo "Full: aws logs get-query-results --query-id $queryid"
    sleep 1
    lgdata=`aws logs get-query-results --query-id $queryid | jq -c ".results[][] | select(.field==\"@message\")"`
    lgval=`echo $lgdata | jq -r ".value"`
    echo $lgval | jq -c ".Processes[]" | grep 'rank":0' | jq
}