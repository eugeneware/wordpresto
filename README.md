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

## Installation

Install via npm into your wordpress plugin folder:

```
$ npm install wordpresto
```

This will install the files into the `node_modules` folder:

To install the latest wordpress, initialize the database, etc, run the command:

```
$ ./node_modules/.bin/wordpresto plugininit
```

You may wish to alias some of these commands into your `package.json`:

``` js
// package.json
{
  ...
  "scripts": {
    "mysqlup": "node_modules/.bin/wordpresto mysqldown",
    "mysqldown": "node_modules/.bin/wordpresto mysqlup",
    "reset": "node_modules/.bin/wordpresto wordpressreset",
    "snapshot": "node_modules/.bin/wordpresto wordpresssnapshot",
    "clean": "node_modules/.bin/wordpresto clean",
    "init": "node_modules/.bin/wordpresto plugininit"
  },
  ...
}
```

That way you can just call:

```
// Installs wordpress test environment
$ npm run init
```

## Commands

### node_modules/.bin/wordpresto clean

Cleans the wordpress installation and wipes the MySQL database in ```db/mysql```

### node_modules/.bin/wordpresto mysqlinit

Initializes a brand new blank MySQL database in ```db/mysql```

### node_modules/.bin/wordpresto wordpressinit

Downloads the latest version of wordpress and install it, and a new database
in ```./wordpress```

It will blow away the existing local MySQL instance in ```db/mysql``` as well
as making a copy or "snapshot" of a fresh wordpress database instance and
stores it away for quick restoration under ```db/mysql.snapshot```.

### node_modules/.bin/wordpresto wordpressreset

Blows away the local MySQL database in ```db/mysql``` and replaces it with
the snapshot copy in ```db/mysql.snapshot```.

This would be the script that you run before running unit or integration tests
to ensure you have a fresh wordpress install for running tests.

### node_modules/.bin/wordpresto wordpresssnapshot

Take the current data in the local ```db/mysql``` directory and back it up with
a "snapshot" in ```db/mysql.snapshot```.

This allows you to modify the live wordpress instance to be the way you want it
prior to testing, and then you execute this command to save a snapshot.

You can then easily roll back to this snapshot by running
```node_modules/.bin/wordpresto wordpressreset```.

### node_modules/.bin/wordpresto mysqlup

Fire up a MySQL server to serve your wordpress data from ```db/mysql```.

This will run on port 3308 by default (which is different from the default
MySQL port). The ```.sock``` file will be stored in
```db/mysql/mysql.wordpress.sock``` by default too so it doesn't interfere
with any other MySQL instances that you're running.

### node_modules/.bin/wordpresto mysqldown

Shuts down the local MySQL wordpress instance.

### node_modules/.bin/wordpresto plugininit

This will install the current directory as a plugin for the local
```./wordpress``` Wordpress installation.

It will also activate the plugin.

## Make variables to override.

By default this script assumes that you're running OS X and that you want to
install worpress in ```~/Sites```. To override these defaults, either
edit the ```APACHE_PATH``` and ```WORDPRESS_URL``` in the Makefile to be the
path where you want to symlink the ```./wordpress``` to so you can access it
through Apache, and the full wordpress URL of your testing wordpress
installation.
