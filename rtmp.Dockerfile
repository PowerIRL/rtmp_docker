FROM alpine:3.21 AS builder

LABEL MAINTAINER Power IRL
LABEL AUTHOR Power IRL
LABEL VERSION 1.0

ARG POWERIRL_RTMP_PORT=1935
ARG POWERIRL_HTTP_PORT=8181

ENV POWERIRL_RTMP_PORT=$POWERIRL_RTMP_PORT
ENV POWERIRL_HTTP_PORT=$POWERIRL_HTTP_PORT

WORKDIR /tmp

# Install dependencies
RUN apk update && apk add --no-cache \
    git \
    build-base \
    libpcre3-dev \
    openssl-dev \
    zlib-dev \
    wget \
    bash \
    make \
    gcc

# Install Nginx and RTMP module
WORKDIR /nginx
RUN wget http://nginx.org/download/nginx-1.20.2.tar.gz && \
    tar -zxvf nginx-1.20.2.tar.gz && \
    git clone --depth 1 https://github.com/arut/nginx-rtmp-module.git && \
    cd nginx-1.20.2 && \
    ./configure --add-module=../nginx-rtmp-module && \
    make -j$(nproc) && make install

# Copy your nginx.conf (ensure this file is in the same directory as your Dockerfile)
COPY nginx.conf /usr/local/nginx/conf/nginx.conf

# Expose the necessary ports (if using default RTMP port 1935)
EXPOSE ${POWERIRL_SRT_PORT}/udp ${POWERIRL_HTTP_PORT}/tcp

# Start nginx in the foreground
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]