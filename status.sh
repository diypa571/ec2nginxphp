

#!/bin/bash
# Diyar Parwana, 2022-02-19
# Exit on error
set -e

echo "Checking if Nginx and PHP-FPM are installed..."

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

# Create a PHP test file
echo "Checking PHP execution via Nginx..."
TEST_FILE="/var/www/html/test.php"
echo "<?php echo 'PHP is working!'; ?>" | sudo tee "$TEST_FILE" > /dev/null

# Check file permissions
EXPECTED_PERMS="755"
ACTUAL_PERMS=$(stat -c "%a" "$TEST_FILE")

if [ "$ACTUAL_PERMS" == "$EXPECTED_PERMS" ]; then
    echo "✅ $TEST_FILE has correct permissions ($EXPECTED_PERMS)."
else
    echo "❌ $TEST_FILE has incorrect permissions ($ACTUAL_PERMS)!"
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
