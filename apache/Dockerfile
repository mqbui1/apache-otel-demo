FROM httpd:2.4

RUN apt-get update && apt-get install -y 
lua5.3 
lua-socket 
lua-dkjson 
&& rm -rf /var/lib/apt/lists/*

COPY httpd.conf /usr/local/apache2/conf/httpd.conf
COPY apache_tracing.lua /usr/local/apache2/conf/apache_tracing.lua
