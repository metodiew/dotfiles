# Database queries

## Create an admin account from phpmyadmin or SQL command

With the following two commands you'll create a new record in `$wpdb->users` and `$wpdb->username` tables. The important part here is to update the table prefix and user ID. Of couse, you have update the username, email and password.
```
INSERT INTO `databasename`.`wp_users` (`ID`, `user_login`, `user_pass`, `user_nicename`, `user_email`, `user_url`, `user_registered`, `user_activation_key`, `user_status`, `display_name`) VALUES ('1', 'admin', MD5('userpasswordhere'), 'Name', 'email@email.com', '', '', '', '0', 'Name');
```

```
INSERT INTO `databasename`.`wp_usermeta` (`umeta_id`, `user_id`, `meta_key`, `meta_value`) VALUES (NULL, '1', 'wp_capabilities', 'a:1:{s:13:"administrator";s:1:"1";}');
```
