#!/bin/bash
docker rm -f $1
docker run --name $1 --hostname heptio-meetup-$1 -ti -v ~/.aws/credentials:/root/.aws/credentials \
-v $(pwd)/../environments/dev/kubeconfig_meetup-dev-eks:/root/.kube/dev \
-v $(pwd)/../environments/dr/kubeconfig_meetup-disaster-eks:/root/.kube/disaster \
-v $(pwd)/example.yaml:/root/example.yaml \
-e KUBECONFIG=/root/.kube/$1 \
-e AWS_DEFAULT_PROFILE=dino \
heptio-meetup-env /bin/bash