set -e
set -x

k3d cluster delete ${CLUSTER_NAME} || true