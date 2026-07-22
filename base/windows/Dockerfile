FROM mcr.microsoft.com/windows/servercore:ltsc2022

WORKDIR /actions-runner/
ENV runner-version="2.335.1"
COPY ./start.ps1 ./

CMD powershell .\start.ps1