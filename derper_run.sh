#!/bin/sh

echo "Starting derper"
export LD_PRELOAD=/usr/lib/libproxyproto.so
exec /usr/bin/derper -hostname=$DERP_DOMAIN -certmode=$DERP_CERT_MODE -certdir=$DERP_CERT_DIR -a=$DERP_ADDR -stun=$DERP_STUN -http-port=$DERP_HTTP_PORT -verify-clients=$DERP_VERIFY_CLIENTS
