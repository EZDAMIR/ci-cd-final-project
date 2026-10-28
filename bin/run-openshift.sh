#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v oc >/dev/null || { echo 'Run this in the authenticated OpenShift lab terminal.' >&2; exit 1; }
oc whoami
oc project
# Check Tekton through a namespaced resource; lab users cannot read CRDs.
oc get pipelines.tekton.dev >/dev/null
mkdir -p evidence/final-project
oc apply -f .tekton/pvc.yml
oc apply -f .tekton/tasks.yml
oc apply -f .tekton/pipeline.yml
oc get pipeline oc-final -o yaml > evidence/final-project/openshift-pipeline.yml
run_name=$(oc create -f .tekton/run.yml -o jsonpath='{.metadata.name}')
echo "Started PipelineRun: $run_name"
deadline=$((SECONDS + 1800))
while true; do
  condition=$(oc get pipelinerun "$run_name" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}')
  if [[ "$condition" == True ]]; then break; fi
  if [[ "$condition" == False ]] || (( SECONDS >= deadline )); then
    oc get pipelinerun "$run_name" -o yaml > evidence/final-project/openshift-pipelinerun.yml
    oc describe pipelinerun "$run_name"
    echo 'Pipeline did not succeed; inspect failed TaskRun logs.' >&2
    exit 1
  fi
  sleep 10
done
bash bin/collect-openshift-evidence.sh "$run_name"
