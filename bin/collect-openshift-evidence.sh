#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
run_name=${1:?Usage: bash bin/collect-openshift-evidence.sh PIPELINERUN_NAME}
mkdir -p evidence/final-project
oc get pipelinerun "$run_name" -o yaml > evidence/final-project/openshift-pipelinerun.yml
condition=$(oc get pipelinerun "$run_name" -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}')
if [[ "$condition" != True ]]; then
  echo "PipelineRun $run_name has not succeeded; status is $condition." >&2
  exit 1
fi
oc get pvc oc-lab-pvc -o yaml > evidence/final-project/openshift-pvc.yml
oc get pipeline oc-final -o yaml > evidence/final-project/openshift-pipeline.yml
oc get taskruns -l "tekton.dev/pipelineRun=$run_name" -o wide > evidence/final-project/openshift-taskruns.txt
if command -v tkn >/dev/null; then
  if ! tkn pipelinerun logs "$run_name" --all > evidence/final-project/openshift-pipeline-logs.txt; then
    echo 'Could not collect pipeline logs with tkn; other evidence will still be collected.' >&2
  fi
fi
oc logs deployment/cicd-app --timestamps > evidence/final-project/openshift-application-logs.txt
oc get deployment,service,route > evidence/final-project/openshift-resources.txt
oc rollout status deployment/cicd-app --timeout=180s
# Check the running application without relying on the public ingress network.
if ! oc exec -i deployment/cicd-app -- python - <<'PY' | tee evidence/final-project/openshift-application-check.txt
import urllib.request

for path in ("/health", "/", "/counters"):
    with urllib.request.urlopen("http://127.0.0.1:8000" + path, timeout=10) as response:
        print(path, response.status, response.read().decode().strip())
PY
then
  oc logs deployment/cicd-app --timestamps > evidence/final-project/openshift-application-logs.txt
  echo 'Internal application check failed; application logs have been saved.' >&2
  exit 1
fi
oc logs deployment/cicd-app --timestamps > evidence/final-project/openshift-application-logs.txt
cp evidence/final-project/openshift-application-logs.txt evidence/final-project/oc-pipeline-application-logs.txt
if ! grep -q 'SERVICERUNNING' evidence/final-project/oc-pipeline-application-logs.txt || ! grep -q ':8000' evidence/final-project/oc-pipeline-application-logs.txt; then
  echo 'Application logs must include SERVICERUNNING and the listener on port 8000. Saved logs are available for inspection.' >&2
  exit 1
fi
{
  oc get pipelinerun "$run_name"
  oc get taskruns -l "tekton.dev/pipelineRun=$run_name"
  oc get deployment cicd-app -o wide
  oc get pvc oc-lab-pvc
} | tee evidence/final-project/openshift-submission-summary.txt
route_host=$(oc get route cicd-app -o jsonpath='{.spec.host}')
if curl --connect-timeout 5 --max-time 10 --fail --silent --show-error "https://$route_host/health" > evidence/final-project/openshift-public-health.txt 2> evidence/final-project/openshift-public-health-error.txt; then
  echo 'Public Route health check passed.'
else
  echo 'Public Route could not be reached from the IDE. Internal application checks passed; see openshift-public-health-error.txt.'
fi
echo "PipelineRun $run_name succeeded. Evidence saved in evidence/final-project/."
echo 'Capture PVC Details, Pipeline Details, and successful PipelineRun screenshots in the console.'
