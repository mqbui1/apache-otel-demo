FROM httpd:2.4

RUN apt-get update && apt-get install -y \
    git \
    cmake \
    build-essential \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

RUN git clone https://github.com/open-telemetry/opentelemetry-cpp-contrib.git

WORKDIR /tmp/opentelemetry-cpp-contrib/instrumentation/apache-httpd

RUN mkdir build && cd build \
    && cmake .. \
    && make -j4 \
    && cp mod_opentelemetry.so /usr/local/apache2/modules/

COPY httpd.conf /usr/local/apache2/conf/httpd.conf
