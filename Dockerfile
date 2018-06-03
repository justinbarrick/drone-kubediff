FROM weaveworks/kubediff:master-caecfa9

RUN apk update && apk add jq

COPY run.sh /run.sh

ENTRYPOINT ["/run.sh"]
