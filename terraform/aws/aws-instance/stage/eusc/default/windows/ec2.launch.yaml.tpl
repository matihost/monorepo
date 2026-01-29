version: 1.1
tasks:
  - task: executeScript
    inputs:
      - frequency: always # or once
        type: powershell
        runAs: localSystem
        content: |-
          # Install IIS
          Install-WindowsFeature -Name Web-Server -IncludeManagementTools
          # Install Chrome Web Browser
          Set-ExecutionPolicy Bypass -Scope Process -Force;
          [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
          Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
          choco install googlechrome -y --force --ignore-checksums -y;
