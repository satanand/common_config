#!/bin/bash
# file: pullmail.sh
source /home/satanand/.gpg-agent-info
monitor() {
  local pid=$1 i=0

  while ps $pid &>/dev/null; do
    if (( i++ > 5 )); then
      echo "Max checks reached. Sending SIGKILL to ${pid}..." >&2
      kill -9 $pid; return 1
    fi

    sleep 10
  done

  return 0
}

read -r pid < ~/.offlineimap/pid

if ps $pid &>/dev/null; then
  echo "Process $pid already running. Exiting..." >&2
  exit 1
fi

/usr/bin/offlineimap -d -u quiet & monitor $! 
/usr/bin/offlineimap -d -u quiet 
