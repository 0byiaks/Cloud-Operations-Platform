#!/bin/bash
dnf update -y
dnf install -y nginx
systemctl start nginx
systemctl enable nginx

cat > /usr/share/nginx/html/index.html <<'HTML'
<!DOCTYPE html>
<html>
  <head><title>NovaCorp</title></head>
  <body>
    <h1>Welcome to NovaCorp</h1>
    <p>Cloud Operations Platform - Dev Environment</p>
  </body>
</html>
HTML