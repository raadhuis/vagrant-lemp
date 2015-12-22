#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

sudo aptitude update -q

# Force a blank root password for mysql
echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections

# Install mysql, nginx, php5-fpm
sudo aptitude install -y mysql-server-5.5 nginx php5-fpm

echo "CREATE USER 'root'@'localhost' IDENTIFIED BY 'root'" | mysql -uroot -proot
echo "CREATE DATABASE modx" | mysql -uroot -proot
echo "GRANT ALL ON modx.* TO 'root'@'localhost'" | mysql -uroot -proot
echo "flush privileges" | mysql -uroot -proot

# Install commonly used php packages
sudo aptitude install -q -y -f php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcached php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php5-xcache

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

  # pass the PHP scripts to FastCGI server listening on /tmp/php5-fpm.sock
  #
  location ~ \.php$ {
    try_files $uri =404;
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass unix:/var/run/php5-fpm.sock;
    fastcgi_index index.php;
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

echo ">>> Installing base packages"
sudo apt-get install  -q -y -f vim curl python-software-properties unzip git-all

sudo locale-gen UTF-8
sudo dpkg-reconfigure locales

echo ">>> Installing node.js"
sudo apt-get install  -q -y -f  python g++ make
sudo add-apt-repository  -q -y -f  ppa:chris-lea/node.js
sudo apt-get update
sudo apt-get install  -q -y -f   nodejs

echo ">>> Installing NPM, Grunt CLI and Bower"
curl -s https://npmjs.org/install.sh | sh
sudo npm install -g grunt-cli bower

echo ">>> Installing Composer"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

echo ">>> Installing Gitify"
git clone https://github.com/modmore/Gitify.git Gitify
cd Gitify
composer install
chmod +x Gitify
echo "export PATH=~/Gitify/:$PATH" | bash

sudo service nginx restart

sudo service php5-fpm restart
