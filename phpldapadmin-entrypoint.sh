#!/bin/bash
set -e

# Wait for OpenLDAP to be available
echo "Waiting for OpenLDAP to be available..."
until nc -z openldap 1389; do
    echo "OpenLDAP not ready, retrying in 5 seconds..."
    sleep 5
done
echo "OpenLDAP is ready!"

# Check if APP_KEY is set and valid, otherwise generate a new one
if [ -z "$APP_KEY" ] || [ "$APP_KEY" = "base64:SomeRandomString" ]; then
    echo "Generating new APP_KEY..."
    APP_KEY=$(php artisan key:generate --show)
    echo "Generated APP_KEY: $APP_KEY"
    touch /app/.env || { echo "Error: Cannot create .env file"; exit 1; }
    chown www-data:www-data /app/.env || echo "Warning: Failed to change ownership of .env"
    chmod 664 /app/.env || echo "Warning: Failed to change permissions of .env"

    # Remove all existing APP_KEY lines, then add the new one at the top
    sed -i '/^APP_KEY=/d' /app/.env
    sed -i '1iAPP_KEY='"$APP_KEY" /app/.env

    # Remove existing LDAP_ lines to avoid duplicates
    sed -i '/^LDAP_/d' /app/.env

    # Add LDAP environment variables
    cat <<EOL >> /app/.env
APP_DEBUG=false
LDAP_CONNECTION=ldap
LDAP_HOST=openldap
LDAP_USERNAME=cn=admin,dc=example,dc=org
LDAP_PASSWORD=adminpassword
LDAP_PORT=1389
LDAP_SSL=false
LDAP_TLS=false
LDAP_NAME="LDAP Server"
EOL

    export APP_KEY
else
    echo "Using provided APP_KEY: $APP_KEY"
fi


# Try to set permissions on Laravel storage directories
echo "Setting permissions on storage directories..."
chown -R www-data:www-data /app/storage || echo "Warning: Failed to change ownership of /app/storage. Continuing..."
chmod -R 775 /app/storage || echo "Warning: Failed to change permissions of /app/storage. Continuing..."

# Clear Laravel caches
php artisan config:clear
php artisan cache:clear
php artisan config:cache

# Start the phpLDAPadmin application
exec php artisan serve --host=0.0.0.0 --port=8080