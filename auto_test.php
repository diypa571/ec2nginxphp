#!/bin/bash

# Function to check if a command exists
check_command() {
    command -v "$1" >/dev/null 2>&1 || { echo "$1 is not installed."; exit 1; }
}

# Check PHP version
check_php_version() {
    php_version=$(php -v | grep -oP '^PHP \K[\d.]+')
    if [[ "$php_version" == "8.2"* ]]; then
        echo "PHP version $php_version is installed - OK"
    else
        echo "PHP version is incorrect. Expected PHP 8.2, but found $php_version"
        exit 1
    fi
}

# Check PHP-FPM status
check_php_fpm() {
    systemctl status php8.2-fpm | grep -q "active (running)" && echo "PHP-FPM is running - OK" || { echo "PHP-FPM is not running."; exit 1; }
}

# Check if Nginx is installed and running
check_nginx() {
    check_command "nginx"
    systemctl status nginx | grep -q "active (running)" && echo "Nginx is running - OK" || { echo "Nginx is not running."; exit 1; }
}

# Check Nginx configuration
check_nginx_config() {
    sudo nginx -t | grep -q "successful" && echo "Nginx configuration is valid - OK" || { echo "Nginx configuration is invalid."; exit 1; }
}

# Check firewall rules for Nginx and SSH
check_firewall() {
    sudo ufw status | grep -q "Nginx HTTP" && echo "Firewall allows Nginx HTTP - OK" || { echo "Firewall does not allow Nginx HTTP."; exit 1; }
    sudo ufw status | grep -q "22" && echo "Firewall allows SSH - OK" || { echo "Firewall does not allow SSH."; exit 1; }
}

# Check if MariaDB is installed and running
check_mariadb() {
    check_command "mysql"
    systemctl status mariadb | grep -q "active (running)" && echo "MariaDB is running - OK" || { echo "MariaDB is not running."; exit 1; }
}

# Check database connection
check_db_connection() {
    mysql -u root -e "SHOW DATABASES;" &>/dev/null && echo "Database connection is successful - OK" || { echo "Database connection failed."; exit 1; }
}

# Check file permissions for /var/www/html
check_permissions() {
    owner=$(stat -c %U:%G /var/www/html)
    if [[ "$owner" == "www-data:www-data" ]]; then
        echo "Correct permissions for /var/www/html - OK"
    else
        echo "Permissions for /var/www/html are incorrect. Expected www-data:www-data, found $owner"
        exit 1
    fi
    chmod_check=$(stat -c %a /var/www/html)
    if [[ "$chmod_check" -eq 755 ]]; then
        echo "Correct file permissions (755) for /var/www/html - OK"
    else
        echo "File permissions for /var/www/html are incorrect. Expected 755, found $chmod_check"
        exit 1
    fi
}

# Run checks
echo "Starting verification process..."

check_php_version
check_php_fpm
check_nginx
check_nginx_config
check_firewall
check_mariadb
check_db_connection
check_permissions

echo "All checks passed successfully!"
