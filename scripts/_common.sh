#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

# dependencies used by the app
PHPVERSION=7.2
pkg_dependencies="php$PHPVERSION-zip php$PHPVERSION-mysql php$PHPVERSION-xml php$PHPVERSION-intl php$PHPVERSION-mbstring php$PHPVERSION-gd php$PHPVERSION-curl php$PHPVERSION-soap php$PHPVERSION-xmlrpc php$PHPVERSION-ldap"

#=================================================
# PERSONAL HELPERS
#=================================================

MOODLE_VERSION=3
MOODLE_RELEASE=7

ynh_install_moodle() {
        ynh_print_info "Downloading Moodle..."
        local MOODLE_APP="https://download.moodle.org/download.php/direct/stable${MOODLE_VERSION}${MOODLE_RELEASE}/moodle-latest-${MOODLE_VERSION}${MOODLE_RELEASE}.tgz"
        local MOODLE_SHA256=${MOODLE_APP}.sha256
        curl -OL ${MOODLE_APP}
        curl -OL ${MOODLE_SHA256}
        ynh_print_info "Verifying integrity..."
        CHECKSUM_STATE=$(echo -n $(sha256sum -c moodle-latest-${MOODLE_VERSION}${MOODLE_RELEASE}.tgz.sha256) | tail -c 2)
        if [ "${CHECKSUM_STATE}" != "OK" ]; then  ynh_print_info "[!!] Checksum does not match!" && exit 1; fi
        ynh_print_info "All seems good, now unpacking moodle-latest-${MOODLE_VERSION}${MOODLE_RELEASE}.tgz"
	tar zxvf moodle-latest-${MOODLE_VERSION}${MOODLE_RELEASE}.tgz 
	mv moodle $final_path
        chown -R $app:$app $final_path
        chmod -R 755 $final_path
        rm moodle-latest-${MOODLE_VERSION}${MOODLE_RELEASE}.*
}

ynh_install_moodle_language() {
	if [ $language = "de" ]; then
		curl -LO https://download.moodle.org/download.php/direct/langpack/${MOODLE_VERSION}.${MOODLE_RELEASE}/de.zip
		unzip de.zip -d $var_root/lang/
		rm de.zip
	fi
	if [ $language = "fr" ]; then
	        curl -LO https://download.moodle.org/download.php/direct/langpack/${MOODLE_VERSION}.${MOODLE_RELEASE}/fr.zip
                unzip fr.zip -d $var_root/lang/
                rm fr.zip
        fi
}

ynh_install_moodle_ldap() {
	mysql <<-EOF
USE ${db_name};
UPDATE mdl_config_plugins SET value='ldap,email' WHERE name='auth';"
UPDATE mdl_config_plugins SET value='ldap://127.0.0.1/' WHERE plugin='auth_ldap' AND name='host_url';"
UPDATE mdl_config_plugins SET value='uid' WHERE plugin='auth_ldap' AND name='user_attribute';"
UPDATE mdl_config_plugins SET value='ou=users,dc=yunohost,dc=org' WHERE plugin='auth_ldap' AND name='contexts';"
UPDATE mdl_config_plugins SET value='givenName' WHERE plugin='auth_ldap' AND name='field_map_firstname';"
UPDATE mdl_config_plugins SET value='sn' WHERE plugin='auth_ldap' AND name='field_map_lastname';"
UPDATE mdl_config_plugins SET value='mail' WHERE plugin='auth_ldap' AND name='field_map_email';"
UPDATE mdl_config_plugins SET value='onlogin' WHERE plugin='auth_ldap' AND (name='field_updatelocal_firstname' OR name='field_updatelocal_lastname' OR name='field_updatelocal_email');"
UPDATE mdl_config_plugins SET value='locked' WHERE plugin='auth_ldap' AND (name='field_lock_firstname' OR name='field_lock_lastname' OR name='field_lock_email');"
EOF

}

# ============= FUTURE YUNOHOST HELPER =============
# Delete a file checksum from the app settings
#
# $app should be defined when calling this helper
#
# usage: ynh_remove_file_checksum file
# | arg: file - The file for which the checksum will be deleted
ynh_delete_file_checksum () {
	local checksum_setting_name=checksum_${1//[\/ ]/_}	# Replace all '/' and ' ' by '_'
	ynh_app_setting_delete $app $checksum_setting_name
}

# Send an email to inform the administrator
#
# usage: ynh_send_readme_to_admin app_message [recipients]
# | arg: app_message - The message to send to the administrator.
# | arg: recipients - The recipients of this email. Use spaces to separate multiples recipients. - default: root
#	example: "root admin@domain"
#	If you give the name of a YunoHost user, ynh_send_readme_to_admin will find its email adress for you
#	example: "root admin@domain user1 user2"
ynh_send_readme_to_admin() {
	local app_message="${1:-...No specific information...}"
	local recipients="${2:-root}"

	# Retrieve the email of users
	find_mails () {
		local list_mails="$1"
		local mail
		local recipients=" "
		# Read each mail in argument
		for mail in $list_mails
		do
			# Keep root or a real email address as it is
			if [ "$mail" = "root" ] || echo "$mail" | grep --quiet "@"
			then
				recipients="$recipients $mail"
			else
				# But replace an user name without a domain after by its email
				if mail=$(ynh_user_get_info "$mail" "mail" 2> /dev/null)
				then
					recipients="$recipients $mail"
				fi
			fi
		done
		echo "$recipients"
	}
	recipients=$(find_mails "$recipients")

	local mail_subject="☁️🆈🅽🅷☁️: \`$app\` has important message for you"

	local mail_message="This is an automated message from your beloved YunoHost server.
Specific information for the application $app.
$app_message
---
Automatic diagnosis data from YunoHost
$(yunohost tools diagnosis | grep -B 100 "services:" | sed '/services:/d')"
	
	# Define binary to use for mail command
	if [ -e /usr/bin/bsd-mailx ]
	then
		local mail_bin=/usr/bin/bsd-mailx
	else
		local mail_bin=/usr/bin/mail.mailutils
	fi

	# Send the email to the recipients
	echo "$mail_message" | $mail_bin -a "Content-Type: text/plain; charset=UTF-8" -s "$mail_subject" "$recipients"
}
