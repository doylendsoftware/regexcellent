#!/usr/bin/python

import os
import re

def finish(msg):
    print msg
    raise SystemExit

def qg(path):
    f=open(path);data=f.read();f.close();return data

print '***************************'
print '*   Regexcellent v0.01    *'
print '* (C) 2017 Thomas Doylend *'
print '***************************'
print ' '

print 'Loading config (c)...'
try:            template_path = qg('c').strip()
except IOError: finish('Unable to load config.')

print 'Loading filename template (t/'+template_path+'.fn)...'
try:            template_fn = qg('t/'+template_path+'.fn')
except IOError: finish('Unable to load filename template.')

print 'Loading data template (t/'+template_path+')...'
try:            template    = qg('t/'+template_path)
except IOError: finish('Unable to load data template.')

print 'Listing (i)...'
try:            input_directory = os.listdir('i')
except IOError: finish('Unable to list (i)')

print 'Found',len(input_directory),'files.'

def apply(template,data):
    parts = template.strip().split('\n')
    parts = [n.split('=>') for n in parts]

    for part in parts:
        #print part
        data = re.sub(part[0],
            lambda pat: part[1].format(
                **{'_'+str(pat.groups().index(n)):n for n in pat.groups()}),
            data,flags=re.DOTALL|re.MULTILINE
        )
    return data

def full_convert(path):
    data = qg('i/'+path)
    reps = re.findall('\\{include (.*?)\\}',data)
    for r in reps:
        data = data.replace('{include '+r+'}',full_convert(r))
    data = apply(template,data)
    return data
print 'Converting...'

for input_file in input_directory:
    data = full_convert(input_file)
    output_fn = apply(template_fn,input_file)
    
    f=open('o/'+output_fn,'w')
    f.write(data)
    f.close()

print 'Done.'
