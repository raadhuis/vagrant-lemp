#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

sudo aptitude update -q

# Force a blank root password for mysql
echo "mysql-server mysql-server/root_password password " | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password " | debconf-set-selections

# Install mysql, nginx, php5-fpm
sudo aptitude install -q -y -f mysql-server mysql-client nginx php5-fpm

# Install commonly used php packages
sudo aptitude install -q -y -f php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcached php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php5-xcache

sudo rm /etc/nginx/sites-available/default
sudo touch /etc/nginx/sites-available/default

sudo cat >> /etc/nginx/sites-available/default <<'EOF'
server {
  listen   80;

  root /var/www/;
  index index.php index.html index.htm;

  # Make site accessible from http://localhost/
  server_name _;

  location / {
    # First attempt to serve request as file, then
    # as directory, then fall back to index.html
    try_files $uri $uri/ /index.html;
  }
  # redirect server error pages to the static page /50x.html
  #
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
  location ~ \.php$ {
          try_files $uri =404;
          fastcgi_split_path_info ^(.+\.php)(.*)$;
          fastcgi_pass   127.0.0.1:9000;
          fastcgi_index  index.php;
          fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
          include fastcgi_params;
          fastcgi_ignore_client_abort on;
          fastcgi_param  SERVER_NAME $http_host;
  }

  location ~ /\.ht {
          deny  all;
  }
}
EOF

sudo touch /usr/share/nginx/html/info.php
sudo cat >> /usr/share/nginx/html/info.php <<'EOF'
<?php phpinfo(); ?>
EOF

echo ">>> Installing base packages"
sudo apt-get install  -q -y -f vim curl python-software-properties unzip git-all

sudo service nginx restart

sudo service php5-fpm restart

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
export PATH=~/Gitify/:$PATH
