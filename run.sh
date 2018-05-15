#!/bin/sh

function slack_notify {
    curl -so /dev/null "$SLACK_URL" --data "$(cat "$1" |jq -Rs \
      --arg drone_build "$DRONE_BUILD_LINK" --arg color "#3CC7F3" \
      --arg channel $SLACK_CHANNEL --arg emoji $SLACK_EMOJI '{
        "channel": $channel,
        "icon_emoji": $emoji,
        "username": "Kubediff",
        "attachments": [
            {
                "color": $color,
                "title": "Planned kubernetes infrastructure changes",
                "title_link": $drone_build,
                "text": .,
            }
        ]
    }')"
}

K8S_CA="${K8S_CA:-${PLUGIN_K8S_CA}}"
K8S_API_URL="${K8S_API_URL:-${PLUGIN_K8S_API_URL}}"
K8S_USER="${K8S_USER:-${PLUGIN_K8S_USER}}"
K8S_TOKEN="${K8S_TOKEN:-${PLUGIN_K8S_TOKEN}}"
MANIFEST_DIRECTORY="${MANIFEST_DIRECTORY:-${PLUGIN_MANIFEST_DIRECTORY}}"
SLACK_URL="${SLACK_URL:-${PLUGIN_SLACK_URL}}"
SLACK_EMOJI="${SLACK_EMOJI:-${PLUGIN_SLACK_EMOJI:-:heart:}}"
SLACK_CHANNEL="${SLACK_CHANNEL:-${PLUGIN_SLACK_CHANNEL}}"

if [ -z "$K8S_CA" ]; then
    echo "K8S_CA is not set."
    exit 1
fi

if [ -z "$K8S_API_URL" ]; then
    echo "K8S_API_URL is not set."
    exit 1
fi

if [ -z "$K8S_USER" ]; then
    echo "K8S_USER is not set."
    exit 1
fi

if [ -z "$K8S_TOKEN" ]; then
    echo "K8S_TOKEN is not set."
    exit 1
fi

if [ -z "$MANIFEST_DIRECTORY" ]; then
    echo "MANIFEST_DIRECTORY is not set."
    exit 1
fi

echo "$K8S_CA" |base64 -d > /tmp/ca.pem

kubectl config set-cluster cluster --server=$K8S_API_URL --certificate-authority="/tmp/ca.pem"
kubectl config set-context cluster --cluster=cluster --namespace=default
kubectl config set-credentials $K8S_USER --token=$K8S_TOKEN
kubectl config set-context cluster --user=$K8S_USER
kubectl config use-context cluster

kubediff $MANIFEST_DIRECTORY |tee > /tmp/output

if [ ! -z "$SLACK_URL" ] && [ ! -z "$SLACK_CHANNEL" ]; then
    slack_notify /tmp/output
else
    echo "Skipping slack notification, SLACK_URL or SLACK_CHANNEL not set."
fi
