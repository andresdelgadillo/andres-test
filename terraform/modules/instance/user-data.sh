#!/bin/bash
yum update -y
amazon-linux-extras install nginx1 -y
systemctl enable nginx

# Nginx configuration

cat <<EOT > /etc/nginx/nginx.conf
events {
	worker_connections 768;
}

http {
    server {
        listen 80;
        server_name localhost INSTANCE_IP;
        root /var/www/andres-test;
        index index.html;
    }
}
EOT

mkdir -p /var/www/andres-test/

cat <<EOF > /var/www/andres-test/index.html
<!doctype html>
<html>
<head>
<title>andres-test</title>
</head>
<body>
<h1>App v0.1 </h1>
<h2>Instance ID: INSTANCE_ID</h2>
<h2>Instance IP: INSTANCE_IP</h2>
</body>
</html>
EOF

chmod 0755 /var/www/andres-test

INSTANCE_IP=$(eval curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
INSTANCE_ID=$(eval curl -s http://169.254.169.254/latest/meta-data/instance-id)

sed -i "s/INSTANCE_IP/$INSTANCE_IP/g" /etc/nginx/nginx.conf
sed -i "s/INSTANCE_IP/$INSTANCE_IP/g" /var/www/andres-test/index.html
sed -i "s/INSTANCE_ID/$INSTANCE_ID/g" /etc/nginx/nginx.conf
sed -i "s/INSTANCE_ID/$INSTANCE_ID/g" /var/www/andres-test/index.html

systemctl start nginx

# Package needed to stress test
amazon-linux-extras install epel -y
yum install stress -y
