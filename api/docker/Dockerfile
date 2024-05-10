from golang:1.22.3 as build

WORKDIR /build
COPY go.mod go.sum Makefile /build/
RUN make deps
COPY * /build/
RUN make build

from alpine:3.19.1

RUN adduser -D demo
USER demo
COPY --from=build /build/build/demo-api /usr/local/bin/
ENTRYPOINT demo-api
