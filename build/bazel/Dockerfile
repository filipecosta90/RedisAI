FROM insready/bazel:latest as baz
FROM ubuntu:latest

COPY --from=baz /usr/bin/bazel* /usr/local/bin/
