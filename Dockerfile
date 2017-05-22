FROM cfplatformeng/tile-generator:v6.0.0

RUN apk add --no-cache make m4 wget

RUN wget -O /usr/local/bin/bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.16-linux-amd64 &&\
    chmod +x /usr/local/bin/bosh

WORKDIR /opt/bosh-release
