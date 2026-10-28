# Hit Counter Service — CI/CD Final Project

Author: Damir (EZDAMIR)

Final project for IBM / Coursera **Continuous Integration and Delivery (CI/CD)**.
Automates linting, unit tests, container builds, and deployment of IBM's sample
Flask Hit Counter service using GitHub Actions, Tekton, and OpenShift.

## Contents

- `.github/workflows/workflow.yml`: flake8 lint and nine nose unit tests.
- `.tekton/tasks.yml`: cleanup, clone, lint, nose, build, and deploy tasks.
- `.tekton/pipeline.yml`: `oc-final` pipeline and shared workspace.
- `.tekton/pvc.yml`: 1 GiB `oc-final-pvc` persistent workspace.
- `.tekton/rbac.yml`: optional account and role binding for other environments.
- `.tekton/run.yml`: repeatable PipelineRun.
- `bin/run-openshift.sh`: deployment and real log collection.
- `SUBMISSION.md`: submission URLs and evidence checklist.

Original practice labs at the repository root remain separate from the final
project manifests in `.tekton/`.

## Continuous integration

Pushes to `main` or `ci-cd-final-project` and pull requests run checkout, Python
setup, dependency installation, flake8 lint, and nose tests. Lint and tests fail
the job on errors. Tests enforce a minimum 80% coverage.
The course starter's pinned dependencies and Python 3.9 are retained for its
legacy nose runner. This is a course compatibility environment.

```sh
python3.9 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
flake8 service tests --count --max-complexity=10 --max-line-length=127 --statistics
nosetests -v --with-spec --spec-color --with-coverage --cover-min-percentage=80
```

## Continuous delivery

In the authenticated Skills Network Cloud IDE terminal:

```sh
git clone --branch ci-cd-final-project https://github.com/EZDAMIR/juphc-tc_pipeline.git ci-cd-final-project
cd ci-cd-final-project
bash bin/run-openshift.sh
```

The script uses the lab's existing `default` service account and installs
resources in the current namespace, creates a PipelineRun,
waits for success, exercises the service, and saves actual cluster output in
`evidence/final-project/`. It requires namespace resource permissions, the
Tekton API, and 1Gi of storage quota on the course's `skills-network-learner`
storage class. Run one pipeline at a time because the
shared PVC is cleaned at the beginning.

Pipeline: **cleanup → git-clone → flake8 → nose → buildah → deploy**.
OpenShift binary Docker builds push to the internal registry. Deployment uses
the built image digest, readiness/liveness probes, and an HTTPS Route on port 8000.

After a successful run, capture these real OpenShift console views:

1. Storage → PersistentVolumeClaims → `oc-final-pvc` → Details:
   `oc-pipelines-console-pvc-details.png`.
2. Pipelines → `oc-final` → Details:
   `oc-pipelines-oc-final.png`.
3. Successful PipelineRun showing all six green tasks:
   `oc-pipelines-oc-green.png`.

## Service

`GET /health`, `GET /`, `GET /counters`, and `POST`, `GET`, `PUT`, `DELETE`
on `/counters/<name>`. Counters are in process memory, as in the starter app.

## Provenance and license

Service, tests, dependency pins, and configuration originate from the
[official IBM template](https://github.com/ibm-developer-skills-network/vselh-ci-cd-final-project-template).
The workflow, Tekton manifests, submission guide, and deployment script were
added for this final project. Apache-2.0; see LICENSE.

