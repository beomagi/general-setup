#!/usr/bin/env python3
import sys
import shutil
import json

windowwidth=80
cpad=" │ "

def coldisplay(columns):
    datas=True
    lineno=0
    while datas:
        pline=[];
        datas=False
        for acolumn in columns:
            colline=""
            if len(acolumn["c"])>=lineno+1:
                datas=True
                colline+=acolumn["c"][lineno]
            pline.append(colline.ljust(acolumn["w"]))
        fullline=cpad.join(pline)
        print(fullline)
        lineno+=1


def files2columns(filelist):
    columns=[]
    for afile in filelist:
        #get lines from file into an array
        with open(afile,'r') as fh:
            ftext=fh.read()
        flines=ftext.splitlines()
        #get max width of lines
        llength=0
        for aline in flines:
            if llength < len(aline): llength=len(aline)
        #add adjusted lines to columns group
        columns.append({"c":flines,"w":llength})
    coldisplay(columns)

if __name__=="__main__":
    filesin=sys.argv[1:]
    windowwidth=shutil.get_terminal_size()
    files2columns(filesin)