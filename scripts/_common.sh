#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

# dependencies used by the app
pkg_dependencies="postgresql"

YNH_PHP_VERSION="7.3"

extra_php_dependencies="php$YNH_PHP_VERSION-common php$YNH_PHP_VERSION-mbstring php$YNH_PHP_VERSION-curl php$YNH_PHP_VERSION-xmlrpc php$YNH_PHP_VERSION-soap php$YNH_PHP_VERSION-zip php$YNH_PHP_VERSION-gd php$YNH_PHP_VERSION-xml php$YNH_PHP_VERSION-intl php$YNH_PHP_VERSION-json php$YNH_PHP_VERSION-pgsql php$YNH_PHP_VERSION-ldap"

#=================================================
# PERSONAL HELPERS
#=================================================

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

# Execute a command as another user
# usage: exec_as USER COMMAND [ARG ...]
exec_as() {
  local USER=$1
  shift 1

  if [[ $USER = $(whoami) ]]; then
    eval "$@"
  else
    sudo -u "$USER" "$@"
  fi
}

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
