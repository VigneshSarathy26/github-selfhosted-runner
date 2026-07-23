#!/bin/bash

cd /actions-runner
curl -o actions-runner-linux-${TARGETARCH}-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${TARGETARCH}-${RUNNER_VERSION}.tar.gz
tar xzf ./actions-runner-linux-${TARGETARCH}-${RUNNER_VERSION}.tar.gz
./config.sh --url $RUNNER_URL --token $RUNNER_TOKEN --labels $RUNNER_LABELS
./run.sh
