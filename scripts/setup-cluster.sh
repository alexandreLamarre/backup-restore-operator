#!/bin/bash

set -e

source $(dirname $0)/version

# waits until all nodes are ready
wait_for_nodes(){
  echo "wait until all agents are ready"
  while :
  do
    readyNodes=1
    statusList=$(kubectl get nodes --no-headers | awk '{ print $2}')
    # shellcheck disable=SC2162
    while read status
    do
      if [ "$status" == "NotReady" ] || [ "$status" == "" ]
      then
        readyNodes=0
        break
      fi
    done <<< "$(echo -e  "$statusList")"
    # all nodes are ready; exit
    if [[ $readyNodes == 1 ]]
    then
      break
    fi
    sleep 1
  done
}

k3d cluster create ${CLUSTER_NAME}


wait_for_nodes

echo "${CLUSTER_NAME} ready"

kubectl cluster-info --context k3d-${CLUSTER_NAME}
kubectl config use-context k3d-${CLUSTER_NAME}
kubectl get nodes -o wide

IMAGE=${REPO}/backup-restore-operator:${TAG}

k3d image import ${IMAGE} -c ${CLUSTER_NAME}
