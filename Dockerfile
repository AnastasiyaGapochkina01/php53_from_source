FROM debian:jessie-slim

ENV PHP_VERSION=5.3.29
ENV PHP_INI_DIR=/usr/local/etc/php
ENV OPENSSL_VERSION=1.0.1t

ENV PHP_BUILD_DEPS \
	autoconf2.13 \
	lemon \
	libbison-dev \
	libcurl4-openssl-dev \
	libfl-dev \
	libmhash-dev \
	libmysqlclient-dev \
	libpcre3-dev \
	libreadline6-dev \
	librecode-dev \
	libsqlite3-dev \
	libssl-dev \
	libldap2-dev \
	libxml2-dev

ENV PHP_RUNTIME_DEPS \
	libmhash2 \
	libmysqlclient18 \
	libpcre3 \
	librecode0 \
	libsqlite3-0 \
	libssl1.0.0 \
	libxml2 \
	xz-utils

ENV BUILD_TOOLS_32 \
	g++-multilib \
	gcc-multilib

ENV RUNTIME_TOOLS \
	ca-certificates \
	curl

ENV BUILD_TOOLS \
	autoconf \
	bison \
	bisonc++ \
	ca-certificates \
	curl \
	dpkg-dev \
	file \
	flex \
	g++ \
	gcc \
	libc-dev \
	make \
	patch \
	pkg-config \
	re2c \
	xz-utils


RUN rm /etc/apt/sources.list
RUN echo "deb http://archive.debian.org/debian-security jessie/updates main" >> /etc/apt/sources.list.d/jessie.list \
  && echo "deb http://archive.debian.org/debian jessie main" >> /etc/apt/sources.list.d/jessie.list

RUN set -eux \
# Install Dependencies
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests --force-yes \
		${BUILD_TOOLS} \
        ${PHP_BUILD_DEPS} \
        ${PHP_RUNTIME_DEPS}

RUN cd /tmp \
	&& mkdir openssl \
	&& update-ca-certificates \
	&& curl -sS -k -L --fail "https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz" -o openssl.tar.gz \
	&& curl -sS -k -L --fail "https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz.asc" -o openssl.tar.gz.asc \
	&& tar -xzf openssl.tar.gz -C openssl --strip-components=1 \
	&& cd /tmp/openssl \
# Build OpenSSL
	&& if [ "$(dpkg-architecture  --query DEB_HOST_ARCH)" = "i386" ]; then \
		setarch i386 ./config -m32; \
	else \
		CFLAGS=-fPIC ./config shared; \
	fi \
	&& make depend \
	&& make -j"$(nproc)" \
	&& make install \
# Cleanup
	&& rm -rf /tmp/* \
# Ensure libs are linked to correct architecture directory
	&& debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)" \
	&& mkdir -p "/usr/local/ssl/lib/${debMultiarch}" \
	&& ln -s /usr/local/ssl/lib/* "/usr/local/ssl/lib/${debMultiarch}/"


RUN set -eux \
	&& mkdir -p ${PHP_INI_DIR}/conf.d \
	&& mkdir -p /usr/src/php


COPY data/docker-php-source /usr/local/bin/
COPY data/php/php-${PHP_VERSION}.tar.xz /usr/src/php.tar.xz
RUN docker-php-source extract

RUN set -eux \
	\
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)" \
	\
	# https://bugs.php.net/bug.php?id=74125
	&& if [ ! -d /usr/include/curl ]; then \
		ln -sT "/usr/include/${debMultiarch}/curl" /usr/local/include/curl; \
	fi \
	&& ln -s /usr/include/x86_64-linux-gnu/curl /usr/local/include/curl


CMD ["/bin/bash"]
