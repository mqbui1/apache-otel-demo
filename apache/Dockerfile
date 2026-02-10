FROM httpd:2.4

# Ensure UIDs exist to prevent getpwuid errors
RUN echo "root:x:0:0:root:/root:/bin/bash" >> /etc/passwd \
 && echo "daemon:x:1:1:daemon:/usr/local/apache2:/bin/sh" >> /etc/passwd

# Copy custom config
COPY httpd.conf /usr/local/apache2/conf/httpd.conf

# Expose port 80
EXPOSE 80

# Start Apache in foreground
CMD ["httpd", "-D", "FOREGROUND"]
