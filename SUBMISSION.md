# Final project submission

Submit these links for questions 1–3:

1. Project README:
   https://github.com/EZDAMIR/juphc-tc_pipeline/blob/ci-cd-final-project/README.md
2. GitHub Actions lint and nose steps:
   https://github.com/EZDAMIR/juphc-tc_pipeline/blob/ci-cd-final-project/.github/workflows/workflow.yml
3. Tekton cleanup and nose tasks:
   https://github.com/EZDAMIR/juphc-tc_pipeline/blob/ci-cd-final-project/.tekton/tasks.yml

Questions 4–8 require actual execution evidence:

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

Actual workflow runs:
https://github.com/EZDAMIR/juphc-tc_pipeline/actions

Do not substitute local logs for GitHub Actions or OpenShift execution evidence.
