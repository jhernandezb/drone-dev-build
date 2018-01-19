FROM golang:1.9 as builder
WORKDIR /drone
RUN  go get -u github.com/drone/drone/cmd/drone-server \
  && go get -u github.com/drone/drone-ui/dist \
  && go get -u golang.org/x/net/context \
  && go get -u golang.org/x/net/context/ctxhttp \
  && go get -u github.com/golang/protobuf/proto \
  && go get -u github.com/golang/protobuf/protoc-gen-go
RUN go build -ldflags '-extldflags "-static"' -o drone-server github.com/drone/drone/cmd/drone-server

FROM  scratch
EXPOSE 8000 9000 80 443
ENV DATABASE_DRIVER=sqlite3
ENV DATABASE_CONFIG=/var/lib/drone/drone.sqlite
ENV GODEBUG=netdns=go
ENV XDG_CACHE_HOME /var/lib/drone
COPY --from=builder /drone/drone-server /bin/
CMD ["/bin/drone-server"]
