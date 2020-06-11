#!/usr/bin/env python3
# pip install pymongo
import time
from pymongo import MongoClient

filename = "/root/my.env"

# parse variable file
envvars = {}
with open(filename, 'r') as variables:
    for line in variables:
        name, value = line.strip().split('=')
        envvars[name] = value

# setup mongodb connection
mongo_url = envvars['MONGO_CONNECTION']
client = MongoClient(mongo_url)
db = client['mybg']

# get last record
last_record = db.entries.find().sort('date', -1).limit(1)

# number of seconds since last record entry time
last_record_time = last_record[0]['date'] / 1000
current_time = time.time()
difference = current_time - last_record_time

# if >5 mins alarm
if difference > 300:
    print(difference,"ohno!")
else:
    print(difference,"ok")
