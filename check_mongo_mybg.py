#!/usr/bin/env python3
"""docstring    """
# ./check_mongo_mybg.py <seconds>
# check number of seconds since last addition to mongo db collection "entries"
import sys
import time
from pymongo import MongoClient

if len(sys.argv) < 2:
    print("usage: %s <seconds>" % sys.argv[0])
    sys.exit(3)

FILENAME = "/root/my.env"
max_time = int(sys.argv[1])

# parse variable file
envvars = {}
with open(FILENAME, 'r') as variables:
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
last_record_time = int(last_record[0]['date'] / 1000)
current_time = int(time.time())
difference = current_time - last_record_time

if difference < max_time:
    print('OK | seconds_since=%d' % difference)
    sys.exit(0)
else:
    print('CRITICAL | seconds_since=%d' % difference)
    sys.exit(2)
