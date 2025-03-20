FROM alpine:3.21 AS builder

ARG POWERIRL_HTTP_PORT=8181
ARG POWERIRL_RTMP_PORT=1935

ENV POWERIRL_HTTP_PORT=$POWERIRL_HTTP_PORT
ENV POWERIRL_RTMP_PORT=$POWERIRL_RTMP_PORT

WORKDIR /tmp

# Install dependencies
RUN apk update && apk add --no-cache \
    git \
    build-base \
    pcre-dev \
    openssl-dev \
    zlib-dev \
    wget \
    bash \
    make \
    gcc

# Install Nginx and RTMP module
WORKDIR /nginx
RUN wget https://nginx.org/download/nginx-1.26.3.tar.gz && \
    tar -zxvf nginx-1.26.3.tar.gz && \
    git clone --depth 1 https://github.com/arut/nginx-rtmp-module.git && \
    cd nginx-1.26.3 && \
    ./configure --add-module=../nginx-rtmp-module && \
    make -j$(nproc) && make install

# Expose the necessary ports (if using default RTMP port 1935)
EXPOSE ${POWERIRL_RTMP_PORT}/udp ${POWERIRL_HTTP_PORT}/tcp

# Start nginx in the foreground
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]