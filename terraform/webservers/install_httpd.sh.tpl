#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h1>Welcome to ACS730 ${prefix}!</h1><h2>My private IP is $myip</h2><h2>Built by Sarvesh Nagar using Terraform!</h2><img src='https://finalproject-sarvesh.s3.us-east-1.amazonaws.com/Sarvesharch.png' alt='Prject Architecture'>"  >  /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd