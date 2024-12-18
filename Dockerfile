# Use an official Ubuntu image as a base
FROM ubuntu:22.04

# Set the maintainer label
LABEL maintainer="diypa571@gmail.com"

# Update and install dependencies
RUN apt-get update && \
    apt-get install -y \
    nginx \
    sudo \
    curl \
    mariadb-server \
    lsb-release \
    software-properties-common \
    && add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y php8.2-fpm php8.2-mysql && \
    apt-get clean

# Allow Nginx HTTP and SSH (port 22)
EXPOSE 80 22

# Copy Nginx config file
COPY default /etc/nginx/sites-available/default

# Set up working directory for web files
WORKDIR /var/www/html

# Set permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Enable and start PHP-FPM service
RUN systemctl enable php8.2-fpm.service

# Start Nginx and PHP-FPM
CMD service php8.2-fpm start && nginx -g 'daemon off;'
