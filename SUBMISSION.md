# Final project resubmission

Use the public repository named **ci-cd-final-project**, branch **main**.

1. README URL:  
   https://github.com/EZDAMIR/ci-cd-final-project/blob/main/README.md

2. GitHub Actions workflow URL:  
   https://github.com/EZDAMIR/ci-cd-final-project/blob/main/.github/workflows/workflow.yml

3. Tekton tasks URL:  
   https://github.com/EZDAMIR/ci-cd-final-project/blob/main/.tekton/tasks.yml

4. Paste the complete contents of `evidence/final-project/cicd-github-validate.txt`.
   This must contain actual successful job step statuses plus the raw job log
   from this repository. Include Set up job, Initialize containers, Checkout,
   Install dependencies, Lint with flake8, Run unit tests with nose,
   Post Checkout, Post Setup Node.js, and Complete job.

5. Upload `oc-pipelines-console-pvc-details.png`.
   Capture the **oc-lab-pvc** Details page showing **Bound**,
   **skills-network-learner**, and a requested capacity of **1Gi**.

6. Upload `oc-pipelines-oc-final.png`.
   Capture the `oc-final` Pipeline Details diagram with
   **cleanup → git-clone → flake8 → nose → buildah → openshift-client**.

7. Upload `oc-pipelines-oc-green.png`.
   Capture the new succeeded PipelineRun with those six green tasks and evidence
   that deployment **cicd-app** was created. The openshift-client task logs show
   the creation and deployment details. If needed, display the console beside
   the genuine output of `oc get deployment cicd-app` in the IDE terminal.

8. Paste the complete contents of
   `evidence/final-project/oc-pipeline-application-logs.txt`.
   It must contain **SERVICERUNNING** exactly and the listener on **port 8000**.

Run `bash bin/run-openshift.sh` in the authenticated lab to generate the new
OpenShift evidence. The collector checks both required application log strings
and saves `openshift-submission-summary.txt` with the actual PipelineRun,
task results, deployment, and PVC status. It does not generate screenshots.

Do not reuse the previous screenshots or logs from deployment hit-counter or
PVC oc-final-pvc, because those names do not meet the evaluated criteria.
