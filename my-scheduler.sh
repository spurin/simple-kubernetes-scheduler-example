#!/bin/bash

echo "🚀 Starting the custom scheduler..."

while true; do
  # Get names of all nodes
  nodes=( $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}') )

  # Get unscheduled pods
  unscheduled_pods=$(kubectl get pods --all-namespaces -o json | jq -r '.items[] | select(.spec.schedulerName=="my-scheduler" and .spec.nodeName==null) | .metadata.namespace + "/" + .metadata.name')

  # Loop over unscheduled pods
  for pod in $unscheduled_pods; do
    # Select a random node
    node=${nodes[$RANDOM % ${#nodes[@]}]}

    # Split the pod into namespace and name
    IFS='/' read -r -a pod_parts <<< "$pod"
    namespace=${pod_parts[0]}
    name=${pod_parts[1]}

    # Create the binding YAML
    binding=$(cat <<EOF
apiVersion: v1
kind: Binding
metadata:
  name: $name
  namespace: $namespace
target:
  apiVersion: v1
  kind: Node
  name: $node
EOF
)

    echo "🎯 Attempting to bind the pod $name in namespace $namespace to node $node"

    # Bind the pod to the node using kubectl create, n.b. it is important that 
    # create is used vs apply as the Binding resource is a special resource that
    # is typically not created or managed directly by users
    echo "$binding" | kubectl create -f - > /dev/null

    echo "🎉 Successfully bound the pod $name to node $node"
  done

  # Sleep before next iteration
  sleep 1
done
