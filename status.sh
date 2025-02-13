#!/bin/bash
# Diyar Parwana, 2022-02-19
# Exit on error
set -e

echo "Checking if Nginx, PHP-FPM, and UFW are installed and configured..."

# Check if Nginx is installed
if ! command -v nginx &> /dev/null; then
    echo "❌ Nginx is NOT installed!"
    exit 1
else
    echo "✅ Nginx is installed."
fi

# Check if PHP is installed
if ! command -v php &> /dev/null; then
    echo "❌ PHP is NOT installed!"
    exit 1
else
    echo "✅ PHP is installed."
fi

# Check if PHP-FPM service is running
if systemctl is-active --quiet php8.3-fpm; then
    echo "✅ PHP-FPM is running."
else
    echo "❌ PHP-FPM is NOT running!"
    exit 1
fi

# Check if php-curl is installed
if dpkg -l | grep -q php-curl; then
    echo "✅ php-curl is installed."
else
    echo "❌ php-curl is NOT installed!"
    exit 1
fi

# Check other required PHP modules
echo "Checking required PHP modules..."
for module in mysqli curl; do
    if php -m | grep -q "$module"; then
        echo "✅ PHP module '$module' is installed."
    else
        echo "❌ PHP module '$module' is missing!"
        exit 1
    fi
done

# Test Nginx configuration
echo "Testing Nginx configuration..."
if sudo nginx -t &> /dev/null; then
    echo "✅ Nginx configuration is OK."
else
    echo "❌ Nginx configuration has errors!"
    exit 1
fi

# Check if Nginx and PHP-FPM services are running
for service in nginx php8.3-fpm; do
    if systemctl is-active --quiet $service; then
        echo "✅ $service is running."
    else
        echo "❌ $service is NOT running!"
        exit 1
    fi
done

# Check if UFW is installed
if ! command -v ufw &> /dev/null; then
    echo "❌ UFW is NOT installed!"
    exit 1
else
    echo "✅ UFW is installed."
fi

# Check if UFW is active
if sudo ufw status | grep -q "active"; then
    echo "✅ UFW is active."
else
    echo "❌ UFW is NOT active!"
    exit 1
fi

# Check if UFW allows HTTP and HTTPS traffic
if sudo ufw status | grep -q "80/tcp.*ALLOW"; then
    echo "✅ UFW allows HTTP (port 80)."
else
    echo "❌ UFW does NOT allow HTTP (port 80)!"
    exit 1
fi

if sudo ufw status | grep -q "443/tcp.*ALLOW"; then
    echo "✅ UFW allows HTTPS (port 443)."
else
    echo "❌ UFW does NOT allow HTTPS (port 443)!"
    exit 1
fi

# Check permissions of /var/www/html folder
EXPECTED_FOLDER_PERMS="755"
ACTUAL_FOLDER_PERMS=$(stat -c "%a" "/var/www/html")

if [ "$ACTUAL_FOLDER_PERMS" == "$EXPECTED_FOLDER_PERMS" ]; then
    echo "✅ /var/www/html has correct permissions ($EXPECTED_FOLDER_PERMS)."
else
    echo "❌ /var/www/html has incorrect permissions ($ACTUAL_FOLDER_PERMS)!"
    exit 1
fi

# Check permissions of /var/www/html/test.php file
EXPECTED_FILE_PERMS="755"
ACTUAL_FILE_PERMS=$(stat -c "%a" "/var/www/html/test.php")

if [ "$ACTUAL_FILE_PERMS" == "$EXPECTED_FILE_PERMS" ]; then
    echo "✅ /var/www/html/test.php has correct permissions ($EXPECTED_FILE_PERMS)."
else
    echo "❌ /var/www/html/test.php has incorrect permissions ($ACTUAL_FILE_PERMS)!"
    exit 1
fi

# Test PHP via Nginx using curl
if curl -sSf http://localhost/test.php | grep -q "PHP is working!"; then
    echo "✅ PHP is working via Nginx!"
else
    echo "❌ PHP is NOT working via Nginx!"
    exit 1
fi

echo "✅ All checks passed successfully!"
