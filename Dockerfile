FROM ubuntu:latest

# Install packages needed for building OpenResty and running WordPress
RUN apt-get update && apt-get install -y curl wget unzip mysql-client

# Install Lua development package and build tools
RUN apt-get update && apt-get install -y liblua5.1-dev build-essential

# Download and extract OpenResty
RUN curl -fsSL https://openresty.org/download/openresty-1.19.9.1.tar.gz -o openresty.tar.gz \
    && tar -xzf openresty.tar.gz \
    && cd openresty-1.19.9.1 \
    && ./configure --prefix=/opt/openresty \
        --with-pcre-jit \
        --with-ipv6 \
        --without-http_redis2_module \
        --with-http_iconv_module \
        --with-http_postgres_module \
        -j8 \
    && make -j8 \
    && make install \
    && rm -rf /openresty-1.19.9.1 \
    && rm /openresty.tar.gz

# Download and extract WordPress
RUN curl -fsSL https://wordpress.org/latest.tar.gz -o wordpress.tar.gz \
    && tar -xzf wordpress.tar.gz \
    && rm wordpress.tar.gz \
    && mv wordpress /var/www/html/

# Copy Nginx configuration file
COPY nginx.conf /opt/openresty/nginx/conf/

# Expose port 80
EXPOSE 80

# Start OpenResty
CMD ["/opt/openresty/nginx/sbin/nginx", "-g", "daemon off;"]
