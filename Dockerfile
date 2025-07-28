# FROM golang AS builder
# WORKDIR /app 
# RUN git clone https://github.com/tailscale/tailscale/ && \
#     cd tailscale && \
#     CGO_ENABLED=0 go build -o derper  ./cmd/derper/

FROM archlinux AS builder
RUN pacman -Sy --noconfirm && \
    pacman -S --noconfirm git base-devel go && \
    rm /var/cache/pacman/pkg/* && \
    mkdir /app
WORKDIR /app 
RUN git clone https://github.com/tailscale/tailscale/ && \
    cd tailscale && \
    CGO_ENABLED=1 go build -o derper  ./cmd/derper/

FROM archlinux AS builder2
# RUN apk add --no-cache ca-certificates git build-base wget && \
#     rm -rf /var/cache/apk/* && \
#     mkdir /src
RUN pacman -Sy --noconfirm && \
    pacman -S --noconfirm git base-devel wget && \
    rm /var/cache/pacman/pkg/* && \
    mkdir /src
WORKDIR /src
RUN git clone https://github.com/msantos/libproxyproto.git . && \
    make all && \
    wget -c https://github.com/nicolas-van/multirun/releases/download/1.1.3/multirun-x86_64-linux-gnu-1.1.3.tar.gz -O - | tar -xz && \
    chmod +x multirun && \
    ls -la

FROM archlinux AS tailscale

WORKDIR /bin
# RUN apk add --no-cache multirun ca-certificates iptables ip6tables iproute2 tailscale && \
#     rm -rf /var/cache/apk/*
RUN pacman -Sy --noconfirm && pacman -S --noconfirm tailscale && rm /var/cache/pacman/pkg/*

COPY ./entrypoint.sh /bin/entrypoint.sh
COPY ./derper_run.sh /bin/derper_run.sh
COPY ./tailscale_run.sh /bin/tailscale_run.sh
COPY --from=builder /app/tailscale/derper /usr/bin/derper
COPY --from=builder2 /src/libproxyproto.so /usr/lib/libproxyproto.so
COPY --from=builder2 /src/multirun /usr/bin/multirun
# COPY --from=builder2 /src/libproxyproto_connect.so /usr/lib/libproxyproto_connect.so

RUN chmod +x /bin/entrypoint.sh && chmod +x /bin/derper_run.sh && chmod +x /bin/tailscale_run.sh

ENV DERP_DOMAIN=example.com
ENV DERP_CERT_DIR=/app/certs
ENV DERP_ADDR=:443
ENV DERP_HTTP_PORT=80
ENV DERP_STUN=true
ENV DERP_VERIFY_CLIENTS=false
ENV DERP_CERT_MODE=manual
ENV LIBPROXYPROTO_DEBUG=true

ENTRYPOINT ["/bin/entrypoint.sh"]
