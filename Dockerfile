# BUILD redisai-cpu-${ARCH}-${OSNICK}:M.m.b

# stretch|bionic|buster
ARG OSNICK=buster

#----------------------------------------------------------------------------------------------
# FROM redisfab/redis-x64-${OSNICK}:5.0.5 AS builder
FROM redis:latest AS builder

ENV X_NPROC "cat /proc/cpuinfo|grep processor|wc -l"

ADD ./ /build
WORKDIR /build

RUN ./deps/readies/bin/getpy2
RUN ./system-setup.py
RUN make deps SHOW=1
RUN make build SHOW=1

#----------------------------------------------------------------------------------------------
# FROM redisfab/redis-x64-${OSNICK}:5.0.5
FROM redis:latest

ENV LD_LIBRARY_PATH /usr/lib/redis/modules/

RUN mkdir -p "$LD_LIBRARY_PATH"

COPY --from=builder /build/bin/redisai.so "$LD_LIBRARY_PATH"
COPY --from=builder /build/deps/install/*.so* "$LD_LIBRARY_PATH"

WORKDIR /data
EXPOSE 6379
CMD ["--loadmodule", "/usr/lib/redis/modules/redisai.so"]
