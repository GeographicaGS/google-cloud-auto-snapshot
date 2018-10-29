#!/bin/bash

# Allow run ./google-cloud-auto-snapshot.sh in a loop if a delay is
# configured ($SLEEP environment variable in seconds) or a flag
# ($FOREVER environment variable set to 'yes').
# Additionally can execute a notification command ($NOTIFY_COMMAND
# environment variable), for example a curl webhook notification
# (e.g. to Slack).

cd "$(dirname "$0")"

run() {
    ./google-cloud-auto-snapshot.sh
    if [ -n "${NOTIFY_COMMAND}" ]; then
        echo "Running notify command: $NOTIFY_COMMAND"
        bash -c "$NOTIFY_COMMAND"
    fi
}

login() {
    gcloud auth activate-service-account --key-file=$GCLOUD_ACCOUNT_FILE
}

if [[ ! -z "${SLEEP}" && -z "${FOREVER}" ]]; then
    # If sleep is defined and not forever, edit forever!
    FOREVER=yes
else
    set -e
fi

# Default to every 6 hours
SLEEP=${SLEEP:=21600}

while true; do
    if [[ ! -z "${GCLOUD_ACCOUNT_FILE}" ]]; then
        login
    fi
    run
    if [ "${FOREVER}" != "yes" ]; then
        break;
    fi
    echo "Sleeping for $SLEEP seconds"
    sleep $SLEEP
done
