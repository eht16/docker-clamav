#!/bin/bash
set -e

if [[ ! -z "${FRESHCLAM_CONF_FILE}" ]]; then
    echo "[bootstrap] FRESHCLAM_CONF_FILE set, copy to /etc/clamav/freshclam.conf"
    mv /etc/clamav/freshclam.conf /etc/clamav/freshclam.conf.bak
    cp -f ${FRESHCLAM_CONF_FILE} /etc/clamav/freshclam.conf
fi

if [[ ! -z "${CLAMD_CONF_FILE}" ]]; then
    echo "[bootstrap] CLAMD_CONF_FILE set, copy to /etc/clamav/clamd.conf"
    mv /etc/clamav/clamd.conf /etc/clamav/clamd.conf.bak
    cp -f ${CLAMD_CONF_FILE} /etc/clamav/clamd.conf
fi

if ! [ -z $HTTPProxyServer ]; then echo "HTTPProxyServer $HTTPProxyServer" >> /etc/clamav/freshclam.conf; fi && \
if ! [ -z $HTTPProxyPort   ]; then echo "HTTPProxyPort $HTTPProxyPort" >> /etc/clamav/freshclam.conf; fi && \

DB_DIR=$(sed -n 's/^DatabaseDirectory\s\(.*\)\s*$/\1/p' /etc/clamav/freshclam.conf )
DB_DIR=${DB_DIR:-'/var/lib/clamav'}
MAIN_FILE="$DB_DIR/main.cvd"
echo "[bootstrap] Checking for Clam DB in $MAIN_FILE"

if [ ! -f ${MAIN_FILE} ]; then
    echo "[bootstrap] Initial clam DB download."
    /usr/bin/freshclam
fi

echo "[bootstrap] Schedule freshclam DB updater."
/usr/bin/freshclam -d

echo "[bootstrap] Run clamav daemon..."
exec /usr/sbin/clamd -c /etc/clamav/clamd.conf
