#!/usr/bin/env python3
import boto3
import sys

tablepad="  "
spacepad=" "

tablepad=tablepad.replace(" ",spacepad)
amidict={}
rowcolumn=0

filter=[]
args=[]

def tagsearch(tagarray,tagname):
    for kv in tagarray:
        key=kv.get("Key")
        val=kv.get("Value")
        if key==tagname:
            return val
    return ""

def getallec2():
    ec2 = boto3.resource('ec2')
    ec2table=[]
    for instance in ec2.instances.all():
        ec2name=tagsearch(instance.tags,'Name')
        ec2ltime=str(instance.launch_time.strftime("%m/%d/%YT%H:%M:%S"))
        
        add=False
        rowdata=[ec2name,instance.id, ec2ltime, instance.image.id, "AMIdatereplace"+instance.image.id, instance.private_ip_address, instance.state['Name'], instance.instance_type]
        if len(args)>0:
            for word in args:
                if word in str(rowdata):
                    add=True
        else:
            add=True
        if add:
            amidict[instance.image.id]="Expired"
            ec2table.append(rowdata)
    return ec2table

def applyamiinfo(data):
    ami = boto3.client('ec2')
    imagelist=list(amidict.keys())
    response = ami.describe_images(ImageIds=imagelist)
    imagelist=response.get('Images',[])
    for oneimage in imagelist:
        amidict[oneimage.get('ImageId')]=oneimage.get('CreationDate')
    for rowchk in range(len(data[0])):
        if "AMIdatereplace" in data[0][rowchk]:
            rowcolumn=rowchk
            break
    for row in data:
        row[rowcolumn]=amidict[row[rowcolumn].replace("AMIdatereplace","")]

def tabledisplay(table):
    colmax=[]
    for row in table: #determine spacing per column
        curcol=0
        for col in row:
            if len(colmax)<(curcol+1):
                colmax.append(len(col))
            if colmax[curcol]<len(col):
                colmax[curcol]=len(col)
            curcol+=1
    for row in table: #actually display the table
        line=""
        curcol=0
        for col in row:
            line+=col.ljust(colmax[curcol],spacepad)+tablepad
            curcol+=1
        print(line)



if __name__=="__main__":
    args=sys.argv[1:]
    data=getallec2()
    applyamiinfo(data)
    tabledisplay(data)

