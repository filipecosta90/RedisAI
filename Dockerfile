# BUILD redisfab/redisai-cpu-${OSNICK}:M.m.b-${ARCH}

# OSNICK=bionic|stretch|buster
ARG OSNICK=stretch

# ARCH=x64|arm64v8|arm32v7
ARG ARCH=x64

#----------------------------------------------------------------------------------------------
# FROM redis:latest AS builder
FROM redisfab/redis-${ARCH}-${OSNICK}:5.0.5 AS builder

ADD ./ /build
WORKDIR /build

RUN ./deps/readies/bin/getpy2
RUN ./system-setup.py
RUN make deps SHOW=1
RUN make build SHOW=1

#----------------------------------------------------------------------------------------------
# FROM redis:latest
FROM redisfab/redis-${ARCH}-${OSNICK}:5.0.5

RUN set -e; apt-get -qq update; apt-get -q install -y libgomp1

ENV REDIS_MODULES /usr/lib/redis/modules

RUN mkdir -p $REDIS_MODULES/

COPY --from=builder /build/bin/redisai.so $REDIS_MODULES/
COPY --from=builder /build/deps/install/*.so* $REDIS_MODULES/

WORKDIR /data
EXPOSE 6379
CMD ["--loadmodule", "/usr/lib/redis/modules/redisai.so"]
