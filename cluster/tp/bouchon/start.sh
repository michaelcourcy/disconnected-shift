#!/bin/sh 
echo `pwd`
while true; do nc -l -p 8080 -c 'echo "HTTP/1.1 200 OK\n\n$content"'; done
