#!/bin/bash

if [ -f /app/.env ]; then
  # enable auto export
  set -a
  # export .env VAR
  source .env
  # disable auto export
  set +a

  # print all ENV logging
  env
fi

if [ ! -f /usr/local/thumbor/thumbor.conf ]; then
  if [ -f /usr/local/thumbor/thumbor.conf.tpl ]; then
    envtpl /usr/local/etc/thumbor.conf.tpl  --allow-missing --keep-template --output /usr/local/thumbor/thumbor.conf
  fi
fi

# If log level is defined we configure it, else use default log_level = info
if [ -n "$LOG_LEVEL" ]; then
    LOG_PARAMETER="-l $LOG_LEVEL"
fi

# Check if thumbor port is defined -> (default port 8888)
if [ -z ${THUMBOR_PORT+x} ]; then
    THUMBOR_PORT=8888
fi

if [ "$1" = 'thumbor' ]; then
    exec thumbor --port=$THUMBOR_PORT --conf=/usr/local/thumbor/thumbor.conf $LOG_PARAMETER
fi

exec "$@"
