#!/bin/sh

ssh root@134.209.159.114 <<EOF
  cd cicdproject
  git pull
  source /opt/envs/cicdproject/bin/activate
  pip install -r requirements.txt
  ./manage.py makemigrations
  ./manage.py migrate  --run-syncdb
  sudo service gunicorn restart
  sudo service nginx restart
  exit
EOF