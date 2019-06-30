# BUILD redisai-cpu-${ARCH}-${OSNICK}:M.m.b

ARG OSNICK=bionic

#----------------------------------------------------------------------------------------------
FROM redislabs/redis-${OSNICK}:5.0.5 AS builder

ENV X_NPROC "cat /proc/cpuinfo|grep processor|wc -l"

ADD ./ /build
WORKDIR /build

RUN ./deps/readies/bin/getpy2
RUN ./system-setup.py
RUN make deps
RUN make -j$(eval "$X_NPROC")

#----------------------------------------------------------------------------------------------
FROM redislabs/redis-${OSNICK}:5.0.5

ENV LD_LIBRARY_PATH /usr/lib/redis/modules/

RUN mkdir -p "$LD_LIBRARY_PATH"

COPY --from=builder /build/bin/redisai.so "$LD_LIBRARY_PATH"
COPY --from=builder /build/deps/install/*.so* "$LD_LIBRARY_PATH"

WORKDIR /data
EXPOSE 6379
CMD ["--loadmodule", "/usr/lib/redis/modules/redisai.so"]
