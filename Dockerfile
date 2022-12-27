FROM golang:latest

ARG HEIMDALL_DIR=/var/lib/heimdall
ENV HEIMDALL_DIR=$HEIMDALL_DIR

RUN mkdir -p $HEIMDALL_DIR

# workaround for arm64 problems (https://github.com/docker/buildx/issues/495#issuecomment-995503425)
RUN ln -s /usr/bin/dpkg-split /usr/sbin/dpkg-split \
    && ln -s /usr/bin/dpkg-deb /usr/sbin/dpkg-deb \
    && ln -s /bin/rm /usr/sbin/rm \
    && ln -s /bin/tar /usr/sbin/tar

RUN apt-get update -y \
    && apt install build-essential git -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${HEIMDALL_DIR}
COPY . .

ARG CGO_ENABLED=1
ARG GOPROXY="https://proxy.golang.org,direct"
RUN --mount=type=cache,target=/root/.cache \
    --mount=type=cache,target=/tmp/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    make -j$(nproc) install

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh

ENV SHELL /bin/bash
EXPOSE 1317 26656 26657

ENTRYPOINT ["entrypoint.sh"]
