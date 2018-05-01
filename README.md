# cron-invadelabs [![Build Status](https://travis-ci.org/invadelabs/cron-invadelabs.svg?branch=master)](https://travis-ci.org/invadelabs/cron-invadelabs) [![Code Coverage](https://codecov.io/gh/invadelabs/cron-invadelabs/branch/master/graph/badge.svg)](https://codecov.io/gh/invadelabs/cron-invadelabs/branch/master)

Supporting scripts for [invadelabs.com](https://invadelabs.com).

| script                    | function                                                           |
| ------------------------- | ------------------------------------------------------------------ |
| check_ddns.sh             | ddns log on cron                                                   |
| check_docker.sh           | slack a message when nagios docker container goes up or down       |
| check_lynis.sh            | mail over weekly cron of lynis audit                               |
| crontab-drewserv.com.sh   | crontab -l from invadelabs host                                    |
| crontab-invadelabs.com.sh | crontab -l from invadelabs host                                    |
| dd-wrt_backup.sh          | simple DD-WRT config backup script                                 |
| gdrive_backup.sh          | google drive backup script on cron for invadelabs.com and drewserv |
| gen_sitemap.sh            | create new mediawiki sitemap for search engines                    |
| mysql_backup.sh           | simple mysql backup script                                         |
| wiki_to_md.sh             | convert mediawiki to markdown, upload to github                    |
