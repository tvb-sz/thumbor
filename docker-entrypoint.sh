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

if [ ! -f /app/thumbor.conf ];then
  # if not exist config file, but exist config template file, then generate it use ENV
  if [ -f /app/thumbor/thumbor.conf.tpl ]; then
    envtpl /app/thumbor.conf.tpl --allow-missing --keep-template --output /app/thumbor.conf
  else
    # none all, touch empty config file
    touch /app/thumbor.conf
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
    exec thumbor --port=$THUMBOR_PORT --conf=/app/thumbor.conf $LOG_PARAMETER
fi

exec "$@"
