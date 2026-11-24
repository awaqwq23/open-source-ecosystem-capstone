"""Find an unexpired signed artifact from a successful main build of this commit."""

import json
import os
import subprocess
import sys


def pages(endpoint):
    result = subprocess.run(
        ["gh", "api", "--paginate", "--slurp", endpoint],
        check=True, capture_output=True, text=True,
    )
    return json.loads(result.stdout)


def select(sha, artifact_id):
    if artifact_id and not artifact_id.isdecimal():
        raise ValueError("Artifact-ID must be a single numeric Actions artifact ID")
    repo = os.environ["GITHUB_REPOSITORY"]
    runs = pages(f"repos/{repo}/actions/workflows/release-apk.yml/runs"
                 f"?branch=main&head_sha={sha}&status=success&per_page=100")
    candidates = []
    for page in runs:
        for run in page["workflow_runs"]:
            if (run["event"] not in ("push", "workflow_dispatch")
                    or run["head_sha"] != sha or run["head_branch"] != "main"
                    or run["conclusion"] != "success"):
                continue
            run_id = run["id"]
            # A rerun may leave artifacts from older, failed attempts.
            name = f"signed-apk-{sha}-{run['run_attempt']}"
            for batch in pages(f"repos/{repo}/actions/runs/{run_id}/artifacts?per_page=100"):
                for asset in batch["artifacts"]:
                    if asset["name"] == name and not asset["expired"]:
                        if not artifact_id or str(asset["id"]) == artifact_id:
                            candidates.append((run_id, asset["id"]))
    if len(candidates) != 1:
        ids = [asset_id for _, asset_id in candidates]
        raise ValueError(f"Expected one accepted main artifact, found {ids}. "
                         "Check build status, retention and the Artifact-ID tag trailer.")
    return candidates[0]


if __name__ == "__main__":
    run_id, artifact_id = select(*sys.argv[1:])
    print(f"run_id={run_id}")
    print(f"artifact_id={artifact_id}")
