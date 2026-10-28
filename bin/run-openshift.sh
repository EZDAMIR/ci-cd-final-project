#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v oc >/dev/null || { echo 'Run this in the authenticated OpenShift lab terminal.' >&2; exit 1; }
oc whoami
oc project
oc get crd pipelines.tekton.dev >/dev/null
mkdir -p evidence/final-project
oc apply -f .tekton/pvc.yml
oc apply -f .tekton/rbac.yml
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
oc get pipelinerun "$run_name" -o yaml > evidence/final-project/openshift-pipelinerun.yml
oc get pvc oc-final-pvc -o yaml > evidence/final-project/openshift-pvc.yml
oc get taskruns -l "tekton.dev/pipelineRun=$run_name" -o wide > evidence/final-project/openshift-taskruns.txt
if command -v tkn >/dev/null; then
  tkn pipelinerun logs "$run_name" --all > evidence/final-project/openshift-pipeline-logs.txt
fi
oc rollout status deployment/hit-counter --timeout=180s
route_host=$(oc get route hit-counter -o jsonpath='{.spec.host}')
curl --fail --silent --show-error "https://$route_host/health"
curl --fail --silent --show-error "https://$route_host/"
curl --fail --silent --show-error "https://$route_host/counters"
oc logs deployment/hit-counter --timestamps > evidence/final-project/openshift-application-logs.txt
oc get deployment,service,route > evidence/final-project/openshift-resources.txt
echo "PipelineRun $run_name succeeded. Evidence saved in evidence/final-project/."
echo 'Capture PVC Details, Pipeline Details, and successful PipelineRun screenshots in the console.'
