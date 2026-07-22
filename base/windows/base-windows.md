# Base Runner Dockerfile (Windows)

This documentation details the Windows base Dockerfile used to build the foundational environment for all Windows GitHub self-hosted runner agents in this project.

## General Information
- **Repository Path**: [base/windows/Dockerfile](file:///D:/repositories/github-selfhosted-runner/base/windows/Dockerfile)
- **Status**: Implemented / Stable
- **Purpose**: Serves as the shared Windows base image containing the core Windows Server Core environment and startup script for GitHub self-hosted runner agents.

## Key Features & Toolchain
- **Parent Image**: `mcr.microsoft.com/windows/servercore:ltsc2022` (Windows Server Core LTSC 2022)
- **Architecture Support**: Configured for `win-x64`.
- **Runner Version**: GitHub Actions runner agent version `2.335.1` (configured via `runner-version` environment variable).

## Installed Packages & System Components

### Package & Component Details

| Package / Tool | Provider / Component | Purpose |
| :--- | :--- | :--- |
| `PowerShell` | Built-in Windows Shell | Execution runtime for start script and administration |
| `System.IO.Compression` | .NET Framework Assembly | Extraction utility for GitHub Actions runner zip packages |
| `Invoke-WebRequest` | PowerShell Utility | Web client tool used to fetch runner binary releases |
| `GitHub Actions Runner` | GitHub Releases (`v2.335.1`) | Core runner agent daemon binary (`actions-runner-win-x64-2.335.1.zip`) |

## Execution Environment
- Working directory configured as `/actions-runner/`.
- Execution entry point executes [start.ps1](file:///D:/repositories/github-selfhosted-runner/base/windows/start.ps1) via PowerShell.
- **Startup Script Operations**:
  - Downloads the GitHub Actions runner agent package (`win-x64`).
  - Extracts the archive into the runner workspace directory.
  - Registers the agent with GitHub using `config.cmd` (using `--url`, `--token`, and `--labels`).
  - Starts the runner listener process via `run.cmd`.

## Dockerfile Source Code

```dockerfile
FROM mcr.microsoft.com/windows/servercore:ltsc2022

WORKDIR /actions-runner/
ENV runner-version="2.335.1"
COPY ./start.ps1 ./

CMD powershell .\start.ps1
```

## Startup Script Source Code (`start.ps1`)

```powershell
Invoke-WebRequest -Uri "https://github.com/actions/runner/releases/download/v${runner-version}/actions-runner-win-x64-${runner-version}.zip" -OutFile "actions-runner-win-x64-${runner-version}.zip"
Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64-${runner-version}.zip", "$PWD")

./config.cmd --url <GitHub URL> --token <PAT> --labels <label>

./run.cmd
```
