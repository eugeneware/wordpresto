# Wordpresto

A testing framework for reliable, repeatable testing of wordpress plugins.

The problem with testing a wordpress plugin is that you need to install
wordpress, a database, initialize and activate your plugin.

Any unit or integration tests ideally should run off the same test environment
each time.

Wordpresto provides a ```Makefile``` that allows you to easily install the
latest Wordpress installation, link it to your ```~/Sites``` folder, or
Apache folder.

It also isolates your MySQL database to run in a local ```db/mysql``` folder so
you can run this wordpress installation completely independently of your main
MySQL database.

## Commands

### make clean

Cleans the wordpress installation and wipes the MySQL database in ```db/mysql```

### make mysqlinit

Initializes a brand new blank MySQL database in ```db/mysql```

### make wordpressinit

Downloads the latest version of wordpress and install it, and a new database
in ```./wordpress```

It will blow away the existing local MySQL instance in ```db/mysql``` as well
as making a copy or "snapshot" of a fresh wordpress database instance and
stores it away for quick restoration under ```db/mysql.snapshot```.

### make wordpressreset

Blows away the local MySQL database in ```db/mysql``` and replaces it with
the snapshot copy in ```db/mysql.snapshot```.

This would be the script that you run before running unit or integration tests
to ensure you have a fresh wordpress install for running tests.

### make wordpresssnapshot

Take the current data in the local ```db/mysql``` directory and back it up with
a "snapshot" in ```db/mysql.snapshot```.

This allows you to modify the live wordpress instance to be the way you want it
prior to testing, and then you execute this command to save a snapshot.

You can then easily roll back to this snapshot by running
```make wordpressreset```.

### make mysqlup

Fire up a MySQL server to serve your wordpress data from ```db/mysql```.

This will run on port 3308 by default (which is different from the default
MySQL port). The ```.sock``` file will be stored in
```db/mysql/mysql.wordpress.sock``` by default too so it doesn't interfere
with any other MySQL instances that you're running.

### make mysqldown

Shuts down the local MySQL wordpress instance.

### make plugininit

This will install the current directory as a plugin for the local
```./wordpress``` Wordpress installation.

It will also activate the plugin.

### make build

This will build the current plugin and exclude all the testing infrastructure
files and build it out to the ```./build``` folder.

## Typical Usage

The main use case would be for plugin development.

1. Firstly fork the repository and clone it to a directory name that will be the
name of your Wordpress Plugin.

2. Rename ```plugin.php``` to the name of your plugin.

3. Run ```make plugininit``` which will install a test installation of
Wordpress and a test MySQL database, and links this plugin to the wordpress
installation and install and activate your plugin, and link this folder to
your Apache folder.

## Make variables to override.

By default this script assumes that you're running OS X and that you want to
install worpress in ```~/Sites```. To override these defaults, either
edit the ```APACHE_PATH``` and ```WORDPRESS_URL``` to be the path where you
want to symlink the ```./wordpress``` to so you can access it through Apache,
and the full wordpress URL of your testing wordpress installation.
