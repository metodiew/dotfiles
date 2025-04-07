# A useful set of WP-CLI commands


## Multisite - loop all subsites and execute a command:

Deletes this transient from all sub-sites
```
wp site list --field=url | xargs -n1 -I % wp --url=% transient delete transient-name --skip-plugins --skip-themes
```
or
List all sites and make them NOT public
```
wp site list --field=url | xargs -n1 -I % wp --url=% option update blog_public 0 --skip-plugins --skip-themes
```

Delete all super-admins
```
wp super-admin list | xargs -n1 wp super-admin remove
```
