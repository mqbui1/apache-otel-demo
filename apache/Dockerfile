# Dockerfile
FROM httpd:2.4

# Install Lua and dependencies
RUN apt-get update && apt-get install -y \
        lua5.3 \
        lua-socket \
        lua-dkjson \
        liblua5.3-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy Apache config
COPY httpd.conf /usr/local/apache2/conf/httpd.conf

# Copy OTEL Lua script
COPY otel.lua /usr/local/apache2/otel/otel.lua
