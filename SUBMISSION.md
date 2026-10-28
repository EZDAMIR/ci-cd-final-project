# Final project submission

Submit these links for questions 1–3:

1. Project README:
   https://github.com/EZDAMIR/juphc-tc_pipeline/blob/ci-cd-final-project/README.md
2. GitHub Actions lint and nose steps:
   https://github.com/EZDAMIR/juphc-tc_pipeline/blob/ci-cd-final-project/.github/workflows/workflow.yml
3. Tekton cleanup and nose tasks:
   https://github.com/EZDAMIR/juphc-tc_pipeline/blob/ci-cd-final-project/.tekton/tasks.yml

Question 5 is ready: [successful run](https://github.com/EZDAMIR/juphc-tc_pipeline/actions/runs/40639645031),
[all step results and test output](evidence/final-project/github-actions-steps.txt),
and [full runner output](evidence/final-project/github-actions-output.txt).
All steps succeeded; nine nose tests passed with 99% coverage.

Questions 4, 6, 7, and 8 still require real OpenShift execution evidence:

| Question | Required artifact | Source |
| --- | --- | --- |
| 4 | oc-pipelines-console-pvc-details.png | OpenShift console, oc-final-pvc Details, Bound status |
| 5 | GitHub Actions output, all steps successful | Actual Actions run logs |
| 6 | oc-pipelines-oc-final.png | OpenShift console, oc-final Pipeline Details |
| 7 | oc-pipelines-oc-green.png | OpenShift console, successful PipelineRun |
| 8 | Application logs text | evidence/final-project/openshift-application-logs.txt |

Run `bash bin/run-openshift.sh` in the authenticated lab terminal to deploy
and collect cluster logs. Capture the three screenshots from the real console
after success. The script saves text evidence, not screenshots.

To collect evidence from an existing successful run without deploying again:

```sh
bash bin/collect-openshift-evidence.sh oc-final-run-67tg7
```

This checks the application inside its running container and saves application
logs before checking the public Route. Public Route access from the IDE is
tested separately with a 10-second timeout and its actual outcome is recorded.

Actual workflow runs:
https://github.com/EZDAMIR/juphc-tc_pipeline/actions

Do not substitute local logs for GitHub Actions or OpenShift execution evidence.
