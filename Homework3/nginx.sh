#! /bin/bash

s3_webserver_log_id="${s3_webserver_log_id}"
sudo apt update --yes
sudo apt install awscli --yes
sudo apt install nginx --yes
sudo chmod 646 /var/www/html/index.nginx-debian.html
sudo echo '<title>Opsschool NginX!</title>' > /var/www/html/index.nginx-debian.html
sudo echo '<h1>Opsschool Nginx!</h1>' >> /var/www/html/index.nginx-debian.html
sudo echo '<h1>'$HOSTNAME'</h1>' >> /var/www/html/index.nginx-debian.html
sudo service nginx start
sudo aws s3 cp /var/log/nginx s3://${s3_webserver_log_id}/$HOSTNAME/logs/ --recursive
sudo chmod 666 /etc/crontab
sudo echo '0 * * * * ubuntu sudo aws s3 cp /var/log/nginx/ s3://${s3_webserver_log_id}/$HOSTNAME/logs/ --recursive' >> /etc/crontab
sudo chmod 644 /etc/crontab