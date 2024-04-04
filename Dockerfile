FROM georgjung/nginx-brotli:mainline-alpine3.18

COPY target/web/ /usr/share/nginx/html

COPY export/nginx.conf /etc/nginx/nginx.conf
