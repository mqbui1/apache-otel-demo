FROM httpd:2.4

RUN apt-get update && apt-get install -y \
    lua5.3 lua-socket lua-dkjson liblua5.3-dev \
    && rm -rf /var/lib/apt/lists/*

COPY httpd.conf /usr/local/apache2/conf/httpd.conf
COPY otel.lua /usr/local/apache2/otel/otel.lua
