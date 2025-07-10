#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <namespace>"
  exit 1
fi

NAMESPACE=$1

echo "🔍 Searching for resources with finalizers in namespace: $NAMESPACE"
echo

kubectl api-resources --namespaced=true -o name | while read -r resource; do
  kubectl get "$resource" -n "$NAMESPACE" -o json 2>/dev/null | jq -r \
    --arg resource "$resource" \
    '.items[] | select(.metadata.finalizers != null) |
     "Kind: \($resource)\nName: \(.metadata.name)\nFinalizers: \(.metadata.finalizers)\n---"'
done
