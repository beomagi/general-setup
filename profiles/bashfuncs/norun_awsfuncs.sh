
setnonprod () { #DEFN
  export AWS_DEFAULT_PROFILE="tr-corporate-preprod"
  export AWS_PROFILE="tr-corporate-preprod"
  echo $AWS_PROFILE > ~/params/AWS_PROFILE.txt
}

setprod () { #DEFN
  export AWS_DEFAULT_PROFILE="tr-corporate-prod"
  export AWS_PROFILE="tr-corporate-prod"
  echo $AWS_PROFILE > ~/params/AWS_PROFILE.txt
}

awslogin () { #DEFN
  cloud-tool --profile $AWS_PROFILE ssh --private-ip "$1"
}

awspass () { #DEFN
  cat ~/pass.txt
}
