# ci-cd-final-project

**Project:** Hit Counter Service CI/CD Pipeline  
**Author:** Damir (EZDAMIR)  
**Course:** IBM / Coursera Continuous Integration and Delivery (CI/CD)  
**Public repository:** https://github.com/EZDAMIR/ci-cd-final-project

This project automates linting, unit tests, container image builds, and OpenShift
deployment of IBM's sample Flask Hit Counter application.

## GitHub Actions

[workflow.yml](.github/workflows/workflow.yml) runs the build job inside a Python
3.9 container. It checks out the repository, sets up Python and Node.js, installs
dependencies, runs **Lint with flake8**, and runs **Run unit tests with nose**.
Nose enforces 80% minimum coverage and writes a JUnit report. A small Node.js
utility validates the report and writes the workflow summary. Node's npm cache
is restored and saved by the setup action.

The runner also records Set up job, Initialize containers, Post Checkout,
Post Setup Node.js, and Complete job. Submission evidence combines the actual
step statuses from GitHub with the full unedited job log.

The course starter's Python 3.9 and legacy nose dependency pins are retained for
course compatibility. The application and its nine API tests originate from the
[official IBM template](https://github.com/ibm-developer-skills-network/vselh-ci-cd-final-project-template).

## Tekton and OpenShift

The `oc-final` pipeline contains these tasks in order:

**cleanup → git-clone → flake8 → nose → buildah → openshift-client**

- Cleanup removes visible and hidden files from `WORKSPACE_SOURCE_PATH`.
- Git clone checks out this repository's `main` branch.
- Flake8 and nose must pass before a container image is built.
- The buildah stage invokes OpenShift's Buildah-based Docker strategy through
  `oc start-build` and returns the immutable image reference.
- The openshift-client task creates deployment **cicd-app**, its service and
  HTTPS Route, configures health probes, and waits for rollout.
- The shared PVC is **oc-lab-pvc**, with storage class
  **skills-network-learner** and a requested capacity of **1Gi**.
- Application startup logs contain **SERVICERUNNING** between asterisks.
  Gunicorn listens on **0.0.0.0:8000**.

The Buildah implementation follows OpenShift's
[Docker strategy documentation](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/pdf/builds_using_buildconfig/index).

In the authenticated Skills Network OpenShift IDE terminal:

```sh
cd /home/project
git clone https://github.com/EZDAMIR/ci-cd-final-project.git ci-cd-resubmission
cd ci-cd-resubmission
bash bin/run-openshift.sh
```

The script uses the lab's existing default service account. It requires room
for the new 1Gi PVC and deployment in the namespace. It saves genuine run,
workspace, deployment, and application log evidence to `evidence/final-project/`.
Public Route reachability is recorded separately with a 10-second timeout.
Run one pipeline at a time because the workspace is cleaned at the beginning.

To recollect evidence from an existing successful run:

```sh
bash bin/collect-openshift-evidence.sh PIPELINERUN_NAME
```

## Submission

See [SUBMISSION.md](SUBMISSION.md) for all eight answers and the three required
screenshots. Use newly captured evidence from this repository and this deployment.

## API

`GET /health`, `GET /`, `GET /counters`, and `POST`, `GET`, `PUT`, `DELETE`
on `/counters/<name>`. Counters are held in process memory.

## License

Apache-2.0; see [LICENSE](LICENSE). Original source attribution is retained.

