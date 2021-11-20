<?php
/**
 * This is a nice set of debugging defines and useful tips and tricks that would help you to set a better environment
 */

/* Debugging Items */
define( 'WP_DEBUG', true ); # Enable debugging
define( 'WP_DEBUG_LOG', true ); # adding debug.log in wp-content folder
define( 'SCRIPT_DEBUG', true ); # showing the not minified assets
define( 'FS_METHOD', 'direct' ); // Allows you to upload/update themes/plugins/core from your localhost without the need of setting FTP server
error_reporting( E_ALL ); # Report all PHP errors
ini_set('display_errors', '1');

/* A few useful commands you'll need over time */
define( 'MEDIA_TRASH', true ); // Enable the "Trash" Feature for Media Files
define( 'DISALLOW_FILE_EDIT', true ); // Disable theme/plugin editor
define( 'WP_POST_REVISIONS', 5 ); // Limit the number of revisions. Or enable them, as some servers have them disabled by default
define( 'ALLOW_UNFILTERED_UPLOADS', true ); // Allow Unfiltered WordPress Uploads for Administrators
