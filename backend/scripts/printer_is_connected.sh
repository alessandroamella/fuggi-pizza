#!/bin/bash

if [ $# -eq 2 ]; then
    VENDOR="0x$1"
    PRODUCT="0x$2"
else
    echo "Usage: $0 vendor_id product_id"
    exit 2
fi

DEVICE=$(lsusb -d $VENDOR:$PRODUCT)

if [ -z "$DEVICE" ]; then
    echo "Stampante non trovata o non connessa"
    exit 1
else
    echo "$VENDOR:$PRODUCT"
fi
