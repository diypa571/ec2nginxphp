
# Diyar Parwana
https://digitalocean.se




sudo apt-get update
sudo apt-get install nginx
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install php8.2-fpm php8.2-mysql
sudo apt-get install mariadb-server
sudo ufw allow 'Nginx HTTP'
sudo ufw allow 22

sudo ufw status
sudo nginx -t
sudo systemctl status php8.2-fpm
sudo systemctl start php8.2-fpm
sudo systemctl enable php8.2-fpm
sudo nano /etc/nginx/sites-available/default
server {
    listen 80;
    server_name your_domain_or_ip;
    root /var/www/html;

    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
sudo nginx -t
sudo systemctl reload nginx
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
sudo chown -R ubuntu:ubuntu /var/www/html
