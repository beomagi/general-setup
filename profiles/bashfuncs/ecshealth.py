#!/usr/bin/env python3
import boto3
import sys
import json

tablepad="  "
spacepad=" "


def tabledisplay(table):
    colmax=[]
    for row in table: #determine spacing per column
        curcol=0
        for col in row:
            col=str(col)
            if len(colmax)<(curcol+1):
                colmax.append(len(col))
            if colmax[curcol]<len(col):
                colmax[curcol]=len(col)
            curcol+=1
    for row in table: #actually display the table
        line=""
        curcol=0
        for col in row:
            col=str(col)
            line+=col.ljust(colmax[curcol],spacepad)+tablepad
            curcol+=1
        print(line)


def getclusterservices(clustername):
    client = boto3.client('ecs')
    slistresponse = client.list_services(cluster=clustername,maxResults=100)
    slist=slistresponse.get('serviceArns',[])
    while slistresponse.get('nextToken')!=None:
        slistresponse = client.list_services(cluster=clustername,maxResults=100,nextToken=slistresponse.get('nextToken'))
        slist+=slistresponse.get('serviceArns')
    
    serviceinfo=[]
    while len(slist)>0:
        services = client.describe_services(cluster=clustername,services=slist[0:10])
        slist = slist[10:]
        for aservice in services.get('services',[]):
            sinfo={}
            sinfo['sname']=aservice.get('serviceName')
            sinfo['sarn']=aservice.get('serviceArn')
            sinfo['status']=aservice.get('status')
            sinfo['desired']=aservice.get('desiredCount')
            sinfo['running']=aservice.get('runningCount')
            sinfo['pending']=aservice.get('pendingCount')
            serviceinfo.append(sinfo)
    return serviceinfo



def getclusterinfo(filter):
    client = boto3.client('ecs')
    clusterlist=[]
    clistresp = client.list_clusters()
    clusterlist += clistresp.get('clusterArns',[])
    while clistresp.get('nextToken')!=None:
        clistresp = client.list_clusters()
        clusterlist += clistresp.get('clusterArns',[])
    chosenlist=[]
    for clusterarn in clusterlist:
        for myclust in args:
            if myclust in clusterarn:
                chosenlist.append(clusterarn)

    clusresp = client.describe_clusters(clusters=chosenlist,include=['ATTACHMENTS','CONFIGURATIONS','SETTINGS','STATISTICS','TAGS'])
    clusterinfo=clusresp.get('clusters',[])
    organizedcinfo=[]
    for clust in clusterinfo:
        cinfo={}
        cinfo["cname"]=clust.get("clusterName","")
        cinfo["arn"]=clust.get("clusterArn","")
        cinfo["status"]=clust.get("status","")
        cinfo["instances"]=clust.get("registeredContainerInstancesCount")
        cinfo["services"]=clust.get("activeServicesCount")
        cinfo["tasks"]=clust.get("runningTasksCount")
        cinfo["services"]=getclusterservices(cinfo["arn"])
        add=False
        for fil in filter:
            if fil in str(cinfo):
                add=True
        if add: organizedcinfo.append(cinfo)
    return(organizedcinfo)

def displaynice(odata):
    for acluster in odata:
        name=acluster.get("cname")
        ec2s=acluster.get("instances")
        print()
        print("{}: {} instances".format(name,ec2s))
        servicetable=[["Name","Desired","Running","Pending"]]
        servicedata=acluster.get("services")
        for aservice in servicedata:
            running=aservice["running"]
            if running<aservice["desired"]: running=str(running)+"*"
            row=[aservice["sname"],aservice["desired"],running,aservice["pending"]]
            servicetable.append(row)
        tabledisplay(servicetable)

if __name__=="__main__":
    args=sys.argv[1:]
    organized=getclusterinfo(args)
    displaynice(organized)

