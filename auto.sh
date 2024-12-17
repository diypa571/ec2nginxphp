#!/bin/bash

# Diyar Parwana
sudo apt-get update -y

# Install Nginx
sudo apt-get install -y nginx

# Add PHP PPA repository
sudo add-apt-repository -y ppa:ondrej/php

# Update package lists again after adding repository
sudo apt-get update -y

# Install PHP 8.2 and MySQLi
sudo apt-get install -y php8.2-fpm php8.2-mysql

# Install MariaDB server
sudo apt-get install -y mariadb-server

# Configure firewall for Nginx and SSH
sudo ufw allow 'Nginx HTTP'
sudo ufw allow 22

# Check UFW status
sudo ufw status

# Test Nginx configuration
sudo nginx -t

# Start PHP-FPM and enable it to start on boot
sudo systemctl start php8.2-fpm
sudo systemctl enable php8.2-fpm
sudo systemctl status php8.2-fpm

# Automatically edit Nginx default site configuration
cat <<EOF | sudo tee /etc/nginx/sites-available/default > /dev/null
server {
    listen 80;
    server_name your_domain_or_ip;
    root /var/www/html;

    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \\.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }

    location ~ /\\.ht {
        deny all;
    }
}
EOF

# Test Nginx configuration again
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Set proper permissions
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
sudo chown -R ubuntu:ubuntu /var/www/html

echo "Installation and configuration complete!"
