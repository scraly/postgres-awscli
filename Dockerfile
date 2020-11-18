FROM alpine:3.12

RUN apk add --update --no-cache \
    curl \
    openssl \
    ca-certificates \
    gzip \
    bash \
    python3 \
    py3-pip \
    postgresql-client \
    && pip3 install --upgrade pip \
    && pip3 install awscli 

WORKDIR /backup

CMD ["/bin/bash"]