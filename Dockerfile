ARG VERSION=latest

FROM mikefarah/yq as yq
FROM aroq/variant:$VERSION as variant
FROM hairyhenderson/gomplate as gomplate

FROM golang:1-alpine as builder

# Install alpine package manifest
COPY Dockerfile.packages.builder.txt /etc/apk/packages.txt
RUN apk add --no-cache --update $(grep -v '^#' /etc/apk/packages.txt)

# Install go-getter
RUN go get github.com/cheggaaa/pb && \
  go install github.com/cheggaaa/pb && \
  go get github.com/hashicorp/go-getter && \
  go install github.com/hashicorp/go-getter/cmd/go-getter

# Install uniconf
RUN go get -v github.com/Masterminds/glide
RUN git clone -b v0.1.2 https://github.com/aroq/uniconf.git /usr/local/go/src/github.com/aroq/uniconf && \
  cd /usr/local/go/src/github.com/aroq/uniconf/ && \
  glide install && \
  CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o uniconf.build && \
  cp uniconf.build /usr/bin/uniconf

FROM alpine:3.10.1
COPY --from=yq /usr/bin/yq /usr/bin/yq
COPY --from=variant /usr/bin/variant /usr/bin/
COPY --from=builder /go/bin/go-getter /usr/bin/
COPY --from=builder /usr/bin/uniconf /usr/bin/
COPY --from=gomplate /gomplate /usr/bin/

# Install alpine package manifest
COPY Dockerfile.packages.txt /etc/apk/packages.txt
RUN apk add --no-cache --update $(grep -v '^#' /etc/apk/packages.txt)
