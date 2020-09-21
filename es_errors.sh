#!/bin/bash

EMAIL_ADDR="$1"

DATE=$(date '+%Y.%m')

STDERROR=$(curl -sS -XPOST "http://192.168.1.125:9200/docker-$DATE,rsyslog-$DATE/_search?size=1000&pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool" : {
      "must" : [
        {"match" : { "message": "warning OR fail OR error OR denied"} },
        {"range": {
          "@timestamp": {
            "gte": "now-1d/d"
          }
        }
        }
      ]
    }
  }
}
'
)

echo "$STDERROR" | jq -r .hits.hits[]._source.message | uniq -w 15 -c -i -f 5 | sort -nr  | mailx -s "Past 24h Errors in Elasticsearch" $EMAIL_ADDR
