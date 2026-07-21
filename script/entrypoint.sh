#!/bin/bash

cd /actions-runner
curl -o actions-runner-linux-x64-2.335.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.335.1/actions-runner-linux-x64-2.335.1.tar.gz
tar xzf ./actions-runner-linux-x64-2.335.1.tar.gz
./config.sh --url $RUNNER_URL --token $RUNNER_TOKEN --labels ${RUNNER_LABELS}
./run.sh
