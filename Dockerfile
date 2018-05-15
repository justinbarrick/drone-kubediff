FROM weaveworks/kubediff:latest

RUN apk update && apk add jq

COPY run.sh /run.sh

ENTRYPOINT ["/run.sh"]
