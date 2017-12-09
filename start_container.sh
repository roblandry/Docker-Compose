#!/bin/bash 
docker run -d  --mount source=scanner_test,target=/data  -p 88:80 --device /dev/bus/usb/003/009 --name scanner_test php_scanner_server1
sudo bindfs -o nonempty --map=www-data/rob /var/lib/docker/volumes/scanner_test/_data /media/8TB/Dockers/scanner1
