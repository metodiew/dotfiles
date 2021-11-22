# Common snippets and scripts

## Resources
* [Query Monitor](https://wordpress.org/plugins/query-monitor/) - the your must have tool, period.
* [BE Media from Production](https://wordpress.org/plugins/be-media-from-production/)
* [wp_mail](https://github.com/johnbillion/wp_mail) by John Blackbourn
* [Rewrite Rules Inspector](https://wordpress.org/plugins/rewrite-rules-inspector/)
* [RTL Tester](https://wordpress.org/plugins/rtl-tester/)
* [Email Log](https://wordpress.org/plugins/email-log/)
* [Cleanup Multisite DB Tables](https://github.com/shawnhooper/delete-orphaned-multisite-tables)


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