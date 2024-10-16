FROM golang as builder

WORKDIR /app 

RUN git clone https://github.com/tailscale/tailscale/ && \
    cd tailscale && \
    CGO_ENABLED=0 go build -o derper  ./cmd/derper/

FROM archlinux:latest as tailscale

WORKDIR /bin
#RUN apk add --no-cache ca-certificates iptables ip6tables iproute2 tailscale && \
#    rm -rf /var/cache/apk/*

RUN pacman -Sy --noconfirm && pacman -S --noconfirm tailscale

COPY --from=builder /app/tailscale/derper /usr/bin/derper

ENV DERP_DOMAIN example.com
ENV DERP_CERT_DIR /app/certs
ENV DERP_ADDR :443
ENV DERP_HTTP_PORT 80
ENV DERP_STUN true
ENV DERP_VERIFY_CLIENTS false
ENV DERP_CERT_MODE manual

CMD /usr/bin/derper -hostname=$DERP_DOMAIN -certmode=$DERP_CERT_MODE -certdir=$DERP_CERT_DIR -a=$DERP_ADDR -stun=$DERP_STUN -http-port=$DERP_HTTP_PORT -verify-clients=$DERP_VERIFY_CLIENTS & /usr/sbin/tailscaled
