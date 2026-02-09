FROM httpd:2.4

RUN apt-get update && apt-get install -y \
    git \
    cmake \
    build-essential \
    libcurl4-openssl-dev \
    apache2-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

RUN git clone https://github.com/open-telemetry/opentelemetry-cpp.git

WORKDIR /tmp/opentelemetry-cpp

RUN mkdir build && cd build \
    && cmake .. \
      -DBUILD_SHARED_LIBS=ON \
      -DWITH_OTLP_HTTP=ON \
      -DCMAKE_BUILD_TYPE=Release \
    && make -j4 \
    && make install

WORKDIR /tmp/opentelemetry-cpp/instrumentation/apache

RUN apxs -c -i -a -n opentelemetry_module mod_opentelemetry.cpp \
    -I/usr/local/include \
    -L/usr/local/lib \
    -lopentelemetry_trace \
    -lopentelemetry_exporter_otlp_http

COPY httpd.conf /usr/local/apache2/conf/httpd.conf
