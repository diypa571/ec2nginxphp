
# Diyar Parwana
https://digitalocean.se



# Uppdatera systemet
sudo apt-get update

# Installera Nginx
sudo apt-get install nginx

# Installera PHP 8.2 och nödvändiga tillägg
sudo apt-get install php8.2-fpm php8.2-mysql

# Installera MariaDB-server 11.2.2
sudo apt-get install mariadb-server

# Tillåt Nginx HTTP-trafik genom brandväggen
sudo ufw allow 'Nginx HTTP'

# Kontrollera brandväggens status
sudo ufw status

# Testa PHP-konfigurationen med Nginx
sudo nginx -t

# Kontrollera status för PHP-FPM
sudo systemctl status php8.2-fpm

# Starta PHP-FPM-tjänsten
sudo systemctl start php8.2-fpm

# Aktivera PHP-FPM så att det startar vid uppstart
sudo systemctl enable php8.2-fpm

# Konfigurera Nginx-servern
sudo nano /etc/nginx/sites-available/default

# Lägg till följande block i Nginx-konfigurationen
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

# Testa Nginx-konfigurationen
sudo nginx -t

# Ladda om Nginx
sudo systemctl reload nginx

# Sätt rätt behörigheter för /var/www/html
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
sudo chown -R ubuntu:ubuntu /var/www/html
