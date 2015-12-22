#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

sudo aptitude update -q


echo "========= Updating OS in Prep For Provision ========="
sudo apt-get update


echo "========= Installing python-sofware-properties ========="
sudo apt-get install -y python-software-properties build-essential


echo "========= Adding Nginx Webserver ========="
sudo add-apt-repository ppa:nginx/development
sudo apt-get update
sudo apt-get install -y nginx


echo "========= Adding PHP ========="
sudo add-apt-repository -y ppa:ondrej/php5-5.6
sudo apt-get update
sudo apt-get install -y php5-fpm php5-cli php5-mcrypt php5-mysql php5-curl
sudo apt-get update
sudo service nginx restart
sudo service php5-fpm restart

echo "========= Adding MySQL ========="
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"
sudo apt-get install -y mysql-server
sudo apt-get install -y mysql-client

echo "CREATE USER 'root'@'localhost' IDENTIFIED BY 'root'" | mysql -uroot -proot
echo "CREATE DATABASE modx" | mysql -uroot -proot
echo "GRANT ALL ON modx.* TO 'root'@'localhost'" | mysql -uroot -proot
echo "flush privileges" | mysql -uroot -proot

sudo rm /etc/nginx/sites-available/default
sudo touch /etc/nginx/sites-available/default

sudo cat >> /etc/nginx/sites-available/default <<'EOF'
server {
  listen   80;

  root /var/www/;
  index index.php index.html index.htm;

  # Make site accessible from http://localhost:8080/
  server_name _;

  # redirect server error pages to the static page /50x.html
  error_page 500 502 503 504 /50x.html;
  location = /50x.html {
    root /usr/share/nginx/html;
  }

  client_max_body_size 30M;
  location / {
          if (!-e $request_filename) {
                  rewrite ^/(.*)$ /index.php?q=$1 last;
          }
  }

  # pass the PHP scripts to FastCGI server listening on /var/run/php5-fpm.sock
  location ~ \.php$ {
    try_files $uri =404;
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass unix:/var/run/php5-fpm.sock;
    fastcgi_index index.php;
    fastcgi_read_timeout 150;
    include fastcgi_params;
  }

  location ~ /\.ht {
          deny  all;
  }
}
EOF

sudo touch /var/www/info.php
sudo cat >> /var/www/info.php <<'EOF'
<?php phpinfo(); ?>
EOF


echo "========= Adding Node ========="
curl --silent --location https://deb.nodesource.com/setup_4.x | sudo bash -
sudo apt-get install -y nodejs
sudo apt-get update

echo "========= Git ========="
sudo apt-get install -y git

echo "======== Composer ========"
#install into /usr/local/bin so we can use composer instead of bin/composer or composer.phar
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

echo "======== Gitify ========"
git clone https://github.com/modmore/Gitify.git Gitify
cd Gitify
composer install
chmod +x Gitify
echo "PATH=~/Gitify/:$PATH" >> ~/.bashrc

sudo apt-get upgrade
sudo apt-get update
