# Final project submission

Submit these links for questions 1–3:

1. Project README:
   https://github.com/EZDAMIR/juphc-tc_pipeline/blob/ci-cd-final-project/README.md
2. GitHub Actions lint and nose steps:
   https://github.com/EZDAMIR/juphc-tc_pipeline/blob/ci-cd-final-project/.github/workflows/workflow.yml
3. Tekton cleanup and nose tasks:
   https://github.com/EZDAMIR/juphc-tc_pipeline/blob/ci-cd-final-project/.tekton/tasks.yml

Question 4 is ready: [successful run](https://github.com/EZDAMIR/juphc-tc_pipeline/actions/runs/40639645031),
[all step results and test output](evidence/final-project/github-actions-steps.txt),
and [full runner output](evidence/final-project/github-actions-output.txt).
All steps succeeded; nine nose tests passed with 99% coverage.

For question 4, copy the full text from
`evidence/final-project/cicd-github-validate.txt`.

Questions 5, 6, 7, and 8 require real OpenShift execution evidence:

| Question | Required artifact | Source |
| --- | --- | --- |
| 4 | cicd-github-validate.txt | Actual GitHub Actions run logs, all steps successful |
| 5 | oc-pipelines-console-pvc-details.png | OpenShift console, oc-final-pvc Details, Bound status, skills-network-learner, 1Gi |
| 6 | oc-pipelines-oc-final.png | OpenShift console, oc-final Pipeline Details |
| 7 | oc-pipelines-oc-green.png | OpenShift console, successful PipelineRun |
| 8 | oc-pipeline-application-logs.txt | Actual application logs with SERVICERUNNING and port 8000 |

Run `bash bin/run-openshift.sh` in the authenticated lab terminal to deploy
and collect cluster logs. Capture the three screenshots from the real console
after success. The script saves text evidence, not screenshots.

To collect evidence from an existing successful run without deploying again:

```sh
bash bin/collect-openshift-evidence.sh PIPELINERUN_NAME
```

This checks the application inside its running container and saves application
logs before checking the public Route. Public Route access from the IDE is
tested separately with a 10-second timeout and its actual outcome is recorded.

For questions 6 and 7, capture a new run with these pipeline labels:
`cleanup`, `git-clone`, `flake8`, `nose`, `buildah`, `deploy`.
The buildah stage uses OpenShift's Docker strategy build, which uses Buildah
to build and push the image. It is invoked through `oc start-build`.
For question 8, use logs from the updated application whose startup banner
contains the exact token `SERVICERUNNING`.

Actual workflow runs:
https://github.com/EZDAMIR/juphc-tc_pipeline/actions

Do not substitute local logs for GitHub Actions or OpenShift execution evidence.
