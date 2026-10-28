#!/usr/bin/env python3
"""Select a Ready pod belonging to the deployment's current ReplicaSet."""

import json
import sys
from pathlib import Path


def select_ready_pod(deployment, replicasets, pods):
    deployment_uid = deployment["metadata"]["uid"]
    revision = deployment["metadata"].get("annotations", {}).get(
        "deployment.kubernetes.io/revision"
    )
    current_replicasets = set()
    for replica in replicasets["items"]:
        metadata = replica["metadata"]
        owners = metadata.get("ownerReferences", [])
        if not any(owner.get("uid") == deployment_uid and owner.get("kind") == "Deployment" for owner in owners):
            continue
        if revision and metadata.get("annotations", {}).get("deployment.kubernetes.io/revision") != revision:
            continue
        if replica.get("spec", {}).get("replicas", 0) > 0:
            current_replicasets.add(metadata["uid"])

    candidates = []
    for pod in pods["items"]:
        metadata = pod["metadata"]
        status = pod.get("status", {})
        if metadata.get("deletionTimestamp") or status.get("phase") != "Running":
            continue
        if not any(owner.get("uid") in current_replicasets and owner.get("kind") == "ReplicaSet" for owner in metadata.get("ownerReferences", [])):
            continue
        if not any(condition.get("type") == "Ready" and condition.get("status") == "True" for condition in status.get("conditions", [])):
            continue
        if not any(container.get("name") == "cicd-app" and container.get("ready") and "running" in container.get("state", {}) for container in status.get("containerStatuses", [])):
            continue
        candidates.append(pod)
    if not candidates:
        raise ValueError("No Ready cicd-app pod exists for the deployment's current ReplicaSet.")
    return max(candidates, key=lambda pod: pod["metadata"].get("creationTimestamp", ""))["metadata"]["name"]


if __name__ == "__main__":
    try:
        documents = [json.loads(Path(path).read_text()) for path in sys.argv[1:]]
        if len(documents) != 3:
            raise ValueError("Expected deployment, ReplicaSet list, and pod list JSON paths.")
        print(select_ready_pod(*documents))
    except (ValueError, KeyError) as error:
        print(error, file=sys.stderr)
        sys.exit(1)
