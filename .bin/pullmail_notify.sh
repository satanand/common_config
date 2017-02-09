#!/bin/bash
# file: pullmail.sh
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



export DISPLAY=127.0.0.1:0.0
export XAUTHORITY=/home/satanand/.Xauthority
source $HOME/.Xdbus; /usr/bin/offlineimap -d -u quiet & monitor $!
declare -a maildirs=("/home/satanand/Maildir/INBOX/new/" "/home/satanand/Maildir/lio_nic_driver/new/" "/home/satanand/Maildir/netdev/new/" "/home/satanand/Maildir/bugzilla/new/")
count=0
for i in "${maildirs[@]}"
do
	let count=$count+`find $i -type f | wc -l`
done
if [ $count -gt 0 ]; then
	source $HOME/.Xdbus; /usr/bin/notify-send -t 5000 -i /home/satanand/art/Logos/mail.gif "You have $count new mail"
fi
