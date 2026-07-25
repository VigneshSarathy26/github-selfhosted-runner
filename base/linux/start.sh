#!/bin/bash
set -e

cd /actions-runner
curl -f -o actions-runner-${TARGETARCH}-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-${TARGETARCH}-${RUNNER_VERSION}.tar.gz
tar xzf ./actions-runner-${TARGETARCH}-${RUNNER_VERSION}.tar.gz
./config.sh --url $RUNNER_URL --token $RUNNER_TOKEN --labels $RUNNER_LABELS
./run.sh
