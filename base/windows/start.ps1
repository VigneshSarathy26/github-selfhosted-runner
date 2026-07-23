
Invoke-WebRequest -Uri "https://github.com/actions/runner/releases/download/v${runner-version}/actions-runner-win-x64-${runner-version}.zip" -OutFile "actions-runner-win-x64-${runner-version}.zip"
Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64-${runner-version}.zip", "$PWD")

./config.cmd --url $RUNNER_URL --token $RUNNER_TOKEN --labels $RUNNER_LABELS

./run.cmd