FROM debian:bookworm-slim as builder

RUN apt-get update && apt-get install -y \
    curl \
    bzip2 \
    iproute2 \
    pkg-config \
    dpkg-dev \
    && apt-get clean

RUN curl -O http://www.litech.org/tayga/tayga-0.9.2.tar.bz2 \
    && tar -xvf tayga-0.9.2.tar.bz2 \
    && cd tayga-0.9.2 \
    && ./configure && make && make install

FROM debian:bookworm-slim

LABEL org.opencontainers.image.authors="thomas@sirmysterion.com"

ENV \
	TAYGA_CONF_DATA_DIR=/var/db/tayga \
	TAYGA_CONF_DIR=/usr/local/etc \
	TAYGA_CONF_IPV4_ADDR=172.18.0.100 \
	TAYGA_IPV6_ADDR=fdaa:bb:1::1 \
	TAYGA_CONF_PREFIX=64:ff9b::/96 \
	TAYGA_CONF_DYNAMIC_POOL=172.18.0.128/25 \
	TAYGA_CONF_FRAG=true

RUN apt-get update && apt-get install -y \
    curl \
    iproute2 \
    && apt-get clean

COPY --from=builder /usr/local/sbin/tayga /usr/local/sbin/tayga

ADD docker-entry.sh /
RUN chmod +x /docker-entry.sh

ENTRYPOINT ["/docker-entry.sh"]
