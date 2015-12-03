#!/bin/bash

# Install Docker
curl -sSL https://get.docker.com/ | sh

# Starting Docker
sudo service docker start

# Retrieving droplet: Redis
docker run --name codecov-redis -d redis

# Retrieving Dockedroplet: Postgdropletes
docker run --name codecov-postgres -d postgres

# create config file
# Creating config file for Codecov: codecov.yml
ip=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}' | tail -1)
random=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1)

echo "# Read more at https://github.com/codecov/enterprise/wiki/Configuration
setup:
  codecov_url: http://$ip
  enterprise_license: demo
  cookie_secret: $random
" > codecov.yml

# Retrieving droplet: Codecov Enterprise
docker run -d -p 80:80 -p 443:443 \
           --link codecov-redis:redis \
           --link codecov-postgres:postgres \
           -v "$PWD/codecov.yml:/codecov.yml" \
           codecov/enterprise

echo "

  _____          _
 / ____|        | |
| |     ___   __| | ___  ___ _____   __
| |    / _ \\ / _\` |/ _ \\/ __/ _ \\ \\ / /
| |___| (_) | (_| |  __/ (_| (_) \\ V /
 \\_____\\___/ \\__,_|\\___|\\___\\___/ \\_/


Thank you for choosing Codecov!

**Next** Please navigate to http://$ip in your browser.

- Your codecov.yml config: $PWD/codecov.yml
- Please generate your own ssl certificates: https://github.com/codecov/enterprise/wiki/SSL
  - The default ones are used for demo only.

-------------------------------------------------------

Request a trial license to have full system access.
While in demo mode: you may only login with one user.
  and reports are deleted after 48 hours.

Thank you!
The Codecov Family

IRC #codecov
https://github.com/codecov/support
enterprise@codecov.io
"
