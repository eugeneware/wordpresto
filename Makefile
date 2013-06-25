MYSQL_DIR = $(shell echo `which mysqld`)
MYSQL_BIN_BASE = $(shell echo `dirname $(MYSQL_DIR)`)
MYSQL_BASE = $(shell echo `dirname $(MYSQL_BIN_BASE)`)
MYSQL_PORT = 3308
CURRENT_DIR = $(shell echo `pwd`)
MODULE_DIR = $(CURRENT_DIR)/node_modules/wordpresto
MYSQL_DATA = $(MODULE_DIR)/db/mysql
MYSQL_SOCKET = /tmp/mysql.wordpress.sock
MYSQL_SNAPSHOT = $(MODULE_DIR)/db/mysql.snapshot
BASE = $(shell echo `basename $(CURRENT_DIR)`)
WORDPRESS_DIR = $(MODULE_DIR)/wordpress

# You may with to customize these two variables
WORDPRESS_URL = $(shell echo http://localhost/~`whoami`/`basename $(CURRENT_DIR)`)
APACHE_PATH = ~/Sites/$(BASE)


# default when type in make
start:
	@echo Read through the Makefile for details
	@echo You can initially create a wordpress installation with:
	@echo $$ make wordpressinit WORDPRESS_URL=$(WORDPRESS_URL)

# clean
clean:
	@echo "Shutting down Mysql..."
	-@mysqladmin shutdown -uroot --port=$(MYSQL_PORT) --socket=$(MYSQL_SOCKET)
	rm -rf $(MYSQL_DATA)/*
	rm -rf $(MYSQL_SNAPSHOT)/*
	rm -rf $(MODULE_DIR)/wordpress/*

# create a new database
mysqlinit:
	rm -rf $(MYSQL_DATA)/*
	$(MYSQL_BASE)/scripts/mysql_install_db --basedir=$(MYSQL_BASE) --datadir=$(MYSQL_DATA)
	mkdir -p $(MYSQL_SNAPSHOT)

# create a brand new wordpress instance
wordpressinit: clean mysqlinit mysqlup
	rm -rf $(MODULE_DIR)/wordpress/*
	$(MODULE_DIR)/bin/installwp.sh "$(WORDPRESS_URL)"
	rm -rf $(MODULE_DIR)/wordpress/wordpress-cli-installer.sh
	@echo "Shutting down Mysql..."
	mysqladmin shutdown -uroot --port=$(MYSQL_PORT) --socket=$(MYSQL_SOCKET)
	cp -R $(MYSQL_DATA)/* $(MYSQL_SNAPSHOT)
	@echo "Starting Mysql..."
	@mysqld --datadir=$(MYSQL_DATA) --user=mysql --port=$(MYSQL_PORT) --socket=$(MYSQL_SOCKET) < /dev/null > /dev/null 2> /dev/null&
	@echo "Linking Apache Dir..."
	ln -sf $(WORDPRESS_DIR) $(APACHE_PATH)
	sleep 3

# reset wordpress database
wordpressreset: mysqldown
	@echo "Resetting MySQL Data to last snapshot"
	rm -rf $(MYSQL_DATA)/*
	cp -R $(MYSQL_SNAPSHOT)/* $(MYSQL_DATA)
	@echo "Starting Mysql..."
	@mysqld --datadir=$(MYSQL_DATA) --user=mysql --port=$(MYSQL_PORT) --socket=$(MYSQL_SOCKET) < /dev/null > /dev/null 2> /dev/null&

# save current database as a snapshot
wordpresssnapshot: mysqldown
	@echo "Saving MySQL Data to snapshot"
	rm -rf $(MYSQL_SNAPSHOT)/*
	cp -R $(MYSQL_DATA)/* $(MYSQL_SNAPSHOT)
	@echo "Starting Mysql..."
	@mysqld --datadir=$(MYSQL_DATA) --user=mysql --port=$(MYSQL_PORT) --socket=$(MYSQL_SOCKET) < /dev/null > /dev/null 2> /dev/null&

# start mysql service
mysqlup:
	@echo "Starting Mysql..."
	@mysqld --datadir=$(MYSQL_DATA) --user=mysql --port=$(MYSQL_PORT) --socket=$(MYSQL_SOCKET) < /dev/null > /dev/null 2> /dev/null&

# stop mysql
mysqldown:
	@echo "Shutting down Mysql..."
	-@mysqladmin shutdown -uroot --port=$(MYSQL_PORT) --socket=$(MYSQL_SOCKET)

~/.composer/bin/wp:
	@curl -s http://wp-cli.org/installer.sh | bash

plugininit: ~/.composer/bin/wp wordpressinit
	@ln -sf `pwd` $(MODULE_DIR)/wordpress/wp-content/plugins/
	@~/.composer/bin/wp --path=$(MODULE_DIR)/wordpress plugin activate "$(BASE)"
	@~/.composer/bin/wp --path=$(MODULE_DIR)/wordpress plugin list

.PHONY: build
build:
	@mkdir -p ./build
	@rm -rf "./build/$(BASE).zip"
	@zip -y9r "./build/$(BASE).zip" . -x ".git/*" "node_modules/*" "*.swp" "build/*"
