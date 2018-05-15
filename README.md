A Drone plugin that uses [kubediff](https://github.com/weaveworks/kubediff) to identify
the expected changes from a directory of kubernetes manifests when applied to your cluster.

It will output expected changes to the build log and, optionally, to a Slack channel.

# Setup

To use, add it to your `.drone.yml`:

```
pipeline:
  kubediff:
    image: justinbarrick/drone-kubediff:dev4
    secrets: [K8S_CA, K8S_API_URL, K8S_USER, K8S_TOKEN]
    manifest_directory: ./manifests/
    slack_url: https://hooks.slack.com/services/WEBHOOK_URL
    slack_channel: "#kubernetes"
    slack_emoji: ":weave:"
```

Settings can be passed in as secrets or plugin settings, other than the Slack settings
all settings are mandatory:

* `MANIFEST_DIRECTORY`: the directory to compare.
* `K8S_CA`: the base64 encoded CA certificate to use when authenticating to Kubernetes.
* `K8S_API_URL`: the Kubernetes API URL.
* `K8S_USER`: the Kubernetes user to use.
* `K8S_TOKEN`: the Kubernetes token to use when authenticating.
* `SLACK_URL`: the Slack [webhook URL](https://api.slack.com/incoming-webhooks) to use.
* `SLACK_USERNAME`: the Slack username to use when sending messages.
* `SLACK_CHANNEL`: the Slack channel to send messages to.
* `SLACK_EMOJI`: the Slack emoji to use as the icon.

# Service user

To create your service user, apply the service account in `./k8s/account.yaml` and fetch
the token:

```
kubectl get secret $(kubectl get serviceaccount drone-deployer -o json |jq -r '.secrets |first |.name') -o json |jq -r .data.token |base64 -d
```

The user created is called `drone-deployer`.
