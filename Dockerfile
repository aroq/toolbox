ARG VARIANT_VERSION=latest
ARG UNICONF_VERSION=0.1.5

FROM mikefarah/yq as yq
FROM aroq/variant:$VARIANT_VERSION as variant
FROM aroq/uniconf:$UNICONF_VERSION as uniconf
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

FROM alpine:3.10.1
COPY --from=yq /usr/bin/yq /usr/bin/yq
COPY --from=variant /usr/bin/variant /usr/bin/
COPY --from=builder /go/bin/go-getter /usr/bin/
COPY --from=gomplate /gomplate /usr/bin/
COPY --from=uniconf /uniconf/uniconf /usr/bin/uniconf

# Install alpine package manifest
COPY Dockerfile.packages.txt /etc/apk/packages.txt
RUN apk add --no-cache --update $(grep -v '^#' /etc/apk/packages.txt)
