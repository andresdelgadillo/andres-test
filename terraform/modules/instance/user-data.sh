#!/bin/bash
yum update -y
amazon-linux-extras install nginx1 -y
systemctl enable nginx
systemctl start nginx

# Package needed to stress test
amazon-linux-extras install epel -y
yum install stress -y


