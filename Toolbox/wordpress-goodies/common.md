# Common snippets and scripts


## SMTP - using SMTP to go and some email plugin defines.
Place these in the wp-config.php and update the proper rules

```
/* SMTP Setup */
define( 'WPMS_ON', true );
define( 'WPMS_MAILER', 'mailgun' );
define( 'WPMS_MAILGUN_API_KEY', 'API-KEY' );
define( 'WPMS_MAILGUN_DOMAIN', 'dmain.com' );
define( 'WPMS_MAILGUN_REGION', 'EU' );
define( 'NOBLOGREDIRECT', 'URL' );
define( 'WPMS_MAIL_FROM', 'email@email.com' );
define( 'WPMS_MAIL_FROM_NAME', 'Email Name' );
```