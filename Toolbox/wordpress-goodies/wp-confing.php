define( 'WP_DEBUG', true );

define( 'SCRIPT_DEBUG', true );

error_reporting( E_ALL );
ini_set( 'display_errors', 'yes' );

define( 'WP_DEBUG_LOG', true );

define( 'FS_METHOD', 'direct' ); // Allows you to upload/update themes/plugins/core from your localhost

define( 'MEDIA_TRASH', true ); // Enable the "Trash" Feature for Media Files 

define( 'DISALLOW_FILE_EDIT', true ); // Disable theme/plugin editor

define( 'WP_POST_REVISIONS', 5 ); // Limit the number of revisions

define( 'ALLOW_UNFILTERED_UPLOADS', true ); // Allow Unfiltered WordPress Uploads for Administrators
