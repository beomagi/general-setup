
eap_check_conf_dockers () { #DEFN checks a config file's dockers to ensure they exist 
	cat $1  | jq ".versions.dockers" | grep ':' | tr -d '," ' | while read line; do
	svc=`echo $line | awk -F ':' '{print $1}'`
	ver=`echo $line | awk -F ':' '{print $2}'`
	ecr=`aws ecr list-images --repository-name eap/tagged/$svc 2>/dev/null | jq -c ".imageIds[]" | grep "\"$ver\""`
	fmt=`echo "$svc $ver                          "|cut -c1-35`
	echo "$fmt $ecr"
	done
}

eap_applogs_nonprd () {

    prevparam=""
    lsfilter="."
    msgfilter="."
    for curparam in $@; do
        echo "prev $prevparam cur $curparam"
        if [ "$prevparam" = "-l" ]; then lsfilter="$curparam"; fi
        if [ "$prevparam" = "-m" ]; then msgfilter="$curparam"; fi
        prevparam=$curparam
    done

    path_to_insightpy="${HOME}/gits/eap_useful_scripts/log-insights/cmdline"
#echo "\"${path_to_insightpy}/insightquery.py\" -f ${path_to_insightpy}/q_appchecks_nonprod.query -message \"$msgfilter\" -logstream \"$lsfilter\""
       "${path_to_insightpy}/insightquery.py"  -f ${path_to_insightpy}/q_appchecks_nonprod.query -message  "$msgfilter"  -logstream  "$lsfilter"
}



eap_applogs_prd () {
	if [[ "$1" == "-help" ]]; then
		echo -e "Run to see recent entries.\n -l logstream-name-filter\n -m message-text-filter"
		return
	fi
	prevparam=""
	lsfilter="."
	msgfilter="."
	for curparam in $@; do
    	if [ "$prevparam" = "-l" ]; then lsfilter="$curparam"; fi
    	if [ "$prevparam" = "-m" ]; then msgfilter="$curparam"; fi
		prevparam=$curparam
	done
    path_to_insightpy="${HOME}/gits/eap_useful_scripts/log-insights/cmdline"
#echo "\"${path_to_insightpy}/insightquery.py\" -f ${path_to_insightpy}/q_appchecks_prod.query -message \"$msgfilter\" -logstream \"$lsfilter\""
       "${path_to_insightpy}/insightquery.py"  -f ${path_to_insightpy}/q_appchecks_prod.query -message  "$msgfilter"  -logstream  "$lsfilter"
}


export path_to_insightpy="${HOME}/gits/eap_useful_scripts/log-insights/cmdline"
alias eap_app_logs_recent_pre="${path_to_insightpy}/insightquery.py -f ${path_to_insightpy}/q_appchecks_nonprod.query | jq -c \".[]\""
alias eap_app_logs_recent_prd="${path_to_insightpy}/insightquery.py -f ${path_to_insightpy}/q_appchecks.query | jq -c \".[]\""
