#! /bin/python3
import sys
import configparser
import json


aws_credentials = configparser.ConfigParser()
aws_credentials.read("/home/jumper/.aws/credentials")
aws_credentials = aws_credentials._sections[sys.argv[1]]

keys = {
"AWS_ACCESS_KEY_ID": aws_credentials["aws_access_key_id"],
"AWS_SECRET_ACCESS_KEY": aws_credentials["aws_secret_access_key"],
"AWS_SESSION_TOKEN": aws_credentials["aws_session_token"]
}

for items in keys:
    print("export {}={}".format(items,keys[items]))
