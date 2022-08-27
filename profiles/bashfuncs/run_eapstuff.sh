
eap_check_conf_dockers () { #DEFN checks a config file's dockers to ensure they exist 
	cat $1  | jq ".versions.dockers" | grep ':' | tr -d '," ' | while read line; do
	svc=`echo $line | awk -F ':' '{print $1}'`
	ver=`echo $line | awk -F ':' '{print $2}'`
	ecr=`aws ecr list-images --repository-name eap/tagged/$svc 2>/dev/null | jq -c ".imageIds[]" | grep "\"$ver\""`
	fmt=`echo "$svc $ver                          "|cut -c1-35`
	echo "$fmt $ecr"
	done
}




