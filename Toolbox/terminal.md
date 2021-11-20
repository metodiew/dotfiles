# Terminal commands and hacks


## List files and directories in the folder and show their size in MB
`$ ls -l --block-size=M`

## Monitor memory usage without top
`$ watch -n 3 -d '/bin/free -m'`


## Display the top 10 IP addresses hitting a webserver
`$ cat /var/log/nginx/access.log | cut -f 1 -d ' ' | sort | \ uniq -c | sort -hr | head -n 10`

