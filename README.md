# Moodle app for YunoHost
[![Integration level](https://dash.yunohost.org/integration/moodle.svg)](https://dash.yunohost.org/appci/app/moodle) ![](https://ci-apps.yunohost.org/ci/badges/moodle.status.svg)   
[![Install Moodle with YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=moodle)

> *This package allows you to install Moodle quickly and simply on a YunoHost server.  
If you don't have YunoHost, please consult [the guide](https://yunohost.org/#/install) to learn how to install it.*

## Overview
[Moodle](https://moodle.org) is a learning platform designed to provide educators, administrators and learners with a single robust, secure and integrated system to create personalised learning environments.

Moodle is widely used around the world by universities, schools, companies and all manner of organisations and individuals.

**Shipped version:** 3.7 with MySQL as database

**IMPORTAND:** During the installation the MySQL format is centrally changed to [Barracuda](https://mariadb.com/kb/en/innodb-file-format/#barracuda). There is an offical support Version with postqress as database: https://github.com/YunoHost-Apps/moodle_ynh

## Screenshots

![](https://docs.moodle.org/39/en/images_en/3/30/Moodle_Modern_Interface2_March_2017.png)

## Demo

* [Official demo](https://sandbox.moodledemo.net/)

## Configuration

How to configure this app: by an admin panel.

## Documentation

 * Official documentation: https://docs.moodle.org/37/en/Main_page

## YunoHost specific features

#### Multi-user support

* Are LDAP and HTTP auth supported? **Yes** 
* Can the app be used by multiple users? **Yes**

## To-do
- [X] Install script
- [X] Remove script
- [ ] Upgrade script
- [X] Backup and Restore scripts (need testing)
- [X] LDAP integration (silent installation only!)
