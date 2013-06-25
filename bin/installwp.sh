#!/bin/sh

# Change these config variables
WORDPRESS_OWNER=`whoami`

INSTALL_PARENT_FOLDER=.
INSTALL_WORDPRESS_FOLDER="node_modules/wordpresto/wordpress"
WORDPRESS_URL="$1"

MYSQL_BIN=`which mysql`
MYSQL_PORT=3308
MYSQL_SOCKET=/tmp/mysql.wordpress.sock
DB_HOST=localhost:${MYSQL_SOCKET}
DB_ROOT_USER=root
DB_ROOT_PASSWORD=

CURRENT_DIR=`pwd`
BASE=`basename ${CURRENT_DIR} | sed s/[^a-zA-Z]//g`
WORDPRESS_DBNAME="test${WORDPRESS_OWNER}_wordpress_${BASE}"
WORDPRESS_DB_USER="${WORDPRESS_OWNER}"
WORDPRESS_DB_PASSWORD="DaCr0n!"
WORDPRESS_ADMIN_PASSWORD="password"

WORDPRESS_EMAIL="${WORDPRESS_OWNER}@noblesamurai.com"
WORDPRESS_BLOG_TITLE="Test Wordpress Installation"
WORDPRESS_LANG="en-US"

# -- Don't Change Anything Below Here

DEST_WORDPRESS_FOLDER=${INSTALL_PARENT_FOLDER}/${INSTALL_WORDPRESS_FOLDER}

# create destination folder
echo "=== Ensure that Destination Folder Exists ==="
mkdir -p ${DEST_WORDPRESS_FOLDER}

# clear out destination folder
rm -rf ${DEST_WORDPRESS_FOLDER}/*

# download wordpress if it doesn't exists
echo "=== Downloading & Unpacking Latest Wordpress ==="
curl -s "http://wordpress.org/latest.tar.gz" | tar --strip-components=1 -xvzf - -C "${DEST_WORDPRESS_FOLDER}"

echo "=== Creating database ==="
${MYSQL_BIN} -u${DB_ROOT_USER} --password=${DB_ROOT_PASSWORD} --port=${MYSQL_PORT} --socket=${MYSQL_SOCKET} -e "DROP DATABASE IF EXISTS ${WORDPRESS_DBNAME}"
${MYSQL_BIN} -u${DB_ROOT_USER} --password=${DB_ROOT_PASSWORD} --port=${MYSQL_PORT} --socket=${MYSQL_SOCKET} -e "CREATE DATABASE ${WORDPRESS_DBNAME}"
${MYSQL_BIN} -u${DB_ROOT_USER} --password=${DB_ROOT_PASSWORD} --port=${MYSQL_PORT} --socket=${MYSQL_SOCKET} -e "GRANT ALL PRIVILEGES ON ${WORDPRESS_DBNAME}.* TO '${WORDPRESS_DB_USER}'@'localhost' IDENTIFIED BY '${WORDPRESS_DB_PASSWORD}' "
${MYSQL_BIN} -u${DB_ROOT_USER} --password=${DB_ROOT_PASSWORD} --port=${MYSQL_PORT} --socket=${MYSQL_SOCKET} -e "FLUSH PRIVILEGES"

# download installation script
echo "=== Downloading wordpress installation script ==="
curl "https://raw.github.com/eugeneware/wordpress-cli-installer/master/wordpress-cli-installer.sh" -o "${DEST_WORDPRESS_FOLDER}/wordpress-cli-installer.sh"
chmod +x "${DEST_WORDPRESS_FOLDER}/wordpress-cli-installer.sh"

# run install script
echo "=== Running wordpress installation script ==="
"${DEST_WORDPRESS_FOLDER}/wordpress-cli-installer.sh" -T "${WORDPRESS_BLOG_TITLE}" -e "${WORDPRESS_EMAIL}" -b "${WORDPRESS_URL}" -l "${WORDPRESS_LANG}" --dbuser="${WORDPRESS_DB_USER}" --dbpass="${WORDPRESS_DB_PASSWORD}" --dbhost="${DB_HOST}" --dbname="${WORDPRESS_DBNAME}" -p "${WORDPRESS_ADMIN_PASSWORD}" "${DEST_WORDPRESS_FOLDER}"
