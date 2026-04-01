#!/bin/bash
set -euo pipefail
dnf install -y httpd
systemctl enable httpd
echo "<h1>Day 20 webserver v2</h1>" > /var/www/html/index.html
sed -i 's/^Listen 80/Listen ${server_port}/' /etc/httpd/conf/httpd.conf
systemctl restart httpd
