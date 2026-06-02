#cloud-config
# Azure place VM configuration in /var/lib/waagent/ovf-env.xml
# VM location of cloud-init configuration: /var/lib/cloud/instance/cloud-config.txt
# Cloud-init output logs: /var/log/cloud-init-output.log
---
repo_update: true
repo_upgrade: all

packages:
 - jq
 - vim
 - less
 - net-tools
 - nginx
 - tinyproxy
 - plocate
 - dnsutils
 - bzip2
 - cron
 - kubectx
 # XRDP setup: https://learn.microsoft.com/en-us/azure/virtual-machines/linux/use-remote-desktop
 - xfce4
 - xfce4-session
 - xrdp
 - firefox
 - dconf-cli


write_files:
  - path: /tmp/install-az.sh
    permissions: '0770'
    content: |
      # auto script, but does not work in distro 26.04 yet
      # curl -fsSL 'https://azurecliprod.blob.core.windows.net/$root/deb_install.sh' | sudo bash
      sudo mkdir -p /etc/apt/keyrings
      curl -sLS https://packages.microsoft.com/keys/microsoft.asc |
        gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
      sudo chmod go+r /etc/apt/keyrings/microsoft.gpg
      # AZ_DIST=$(lsb_release -cs)
      AZ_DIST="noble" # 26.04 is not yet supported by Microsoft, but noble is compatible and works fine
      echo "Types: deb
      URIs: https://packages.microsoft.com/repos/azure-cli/
      Suites: $${AZ_DIST}
      Components: main
      Architectures: $(dpkg --print-architecture)
      Signed-by: /etc/apt/keyrings/microsoft.gpg" | sudo tee /etc/apt/sources.list.d/azure-cli.sources
      apt update
      apt -y install azure-cli
      az config set extension.dynamic_install_allow_preview=true
      az config set extension.use_dynamic_install=yes_without_prompt
      az aks install-cli
      az login --identity
      # use system managed identity, bc sometime user assigned identity is not ... assigned to VM
      # az login --identity --client-id ${user_assigned_identity_client_id}

  - path: /root/create-rdp-user.sh
    permissions: '0700'
    content: |
      #!/bin/bash
      set -e
      username="$${1:?Username is required, usage: create-rdp-user.sh <username> <password>}"
      password="$${2:?Password is required, usage: create-rdp-user.sh <username> <password>}"
      if id "$username" &>/dev/null; then
        echo "User $username already exists"
      else
        useradd -m -s /bin/bash -G adm,sudo,cdrom,dip,lxd "$username"
        echo "$username:$password" | chpasswd
        echo xfce4-session >/home/$username/.xsession
        chown $username:$username /home/$username/.xsession
        echo "User $username created with password $password"
      fi
%{ if length(vars) > 0 && vars[0] != "" }
  - path: /etc/resticprofile/key
    content: password
    permissions: '0600'
  - path: /etc/resticprofile/profiles.yaml
    permissions: '0640'
    content: |
      version: 1

      global:
        scheduler: crond
        # run 'snapshots' when no command is specified when invoking resticprofile
        default-command: snapshots
        # initialize a repository if none exist at location
        initialize: true
        # priority is using priority class on windows, and nice on unixes
        priority: low
        # resticprofile won't start a profile if there's less than 100MB of RAM available
        min-memory: 100

      default:
        repository: azure:${vars[2]}:/${vm_name}
        option: azure.connections=3
        env:
          AZURE_ACCOUNT_NAME: ${vars[1]}
          AZURE_RESOURCE_GROUP: ${vars[0]}
          AZURE_FORCE_CLI_CREDENTIAL: true
          # AZURE_CLIENT_ID: "

        password-file: key

        backup:
          verbose: true
          source:
            - /home
            - /opt
            - /srv
            - /etc/ssh
            - /etc/sudoers
            - /etc/sudoers.d
            - /etc/passwd
            - /etc/shadow
            - /etc/group
            - /etc/gshadow
            - /etc/subuid
            - /etc/subgid
            - /var/spool/cron


          exclude:
            - /proc
            - /sys
            - /dev
            - /run
            - /tmp
            - /mnt
            - /media
            - /var/cache
            - /var/tmp
            - /var/lib/docker
            - /var/lib/containerd
            - /var/lib/kubelet/pods
            # Azure agent / provisioning (IMPORTANT)
            - /var/lib/waagent
            - /var/lib/azure
            - /var/lib/cloud
            - /run/cloud-init
            - /var/lib/waagent-extensions

            # Optional
            - /var/log
            # GNOME / desktop noise (important)
            - /home/*/.cache
            - /home/*/.local/share/Trash

            # Azure SDK / CLI tools (your current exclusions are OK)
            - /opt/az
            - /opt/microsoft
            # Exclude cache and temporary files in home directories
            - /home/*/thinclient_drives
            - "**/cache/**"
            - "**/.cache/**"
            - "**/*Cache*/**"
            - /home/*/.local/share
            - /home/*/.local/lib
            - /home/*/.gvfs
            - /home/*/.m2/repository
            - /home/*/.nvm
            - /home/*/.npm
            - "**/node_modules/**"
            - /home/*/.serverless
            - /home/*/Dropbox
            - /home/*/OneDrive
            - /home/*/GDrive
            - /home/*/go
            - /home/*/.vagrant.d/boxes
            - "/home/*/VirtualBox VMs"
            - /home/*/.sdkman
            - /home/*/snap
            - /home/*/.vscode
            # Exclude mount points (important to avoid backing up other filesystems)
            - /media
            - /mnt

            # Optional - exclude large media files in home directories
            - /home/*/Pictures/**
            - /home/*/Music/**
            - /home/*/Videos/**
            - /home/*/Downloads/**

          exclude-caches: true
          one-file-system: true

          # daily
          schedule: daily
          schedule-permission: system
          schedule-lock-wait: 45m
          schedule-after-network-online: true

          #
          # Optional but HIGHLY recommended for GNOME consistency
          #
          run-before:
            # use system managed identity, bc sometime user assigned identity is not ... assigned to VM
            # - az login --identity --client-id ${user_assigned_identity_client_id}
            - az login --identity
            - mkdir -p /tmp/restic-desktop
            - dconf dump / > /tmp/restic-desktop/dconf.ini || true

          run-after:
            - rm -rf /tmp/restic-desktop

        retention:
          after-backup: true
          keep-daily: 7
          keep-weekly: 4
          keep-monthly: 6
          keep-yearly: 2
          prune: true

      # sudo apt install cron
      # az login --identity
      # resticprofile --config /etc/resticprofile/profiles.yaml schedule --all
      # resticprofile --config /etc/resticprofile/profiles.yaml schedule --list
      # crontab -l
      # resticprofile --config /etc/resticprofile/profiles.yaml schedule --list
      # resticprofile --config /etc/resticprofile/profiles.yaml backup
%{ endif }

# cloud-init creates a final script in: /var/lib/cloud/instance/scripts/runcmd
runcmd:
 # tmp is only 444MB by default, which is too small for the Azure CLI install
 - mount -o remount,size=4G /tmp
 - /tmp/install-az.sh
 - systemctl enable --now nginx
 - echo -n "${ssh_pub}" |base64 -d > /home/${admin_username}/.ssh/id_rsa.pub
 - echo -n "${ssh_key}" |base64 -d > /home/${admin_username}/.ssh/id_rsa
 - cat /home/${admin_username}/.ssh/id_rsa.pub >> /home/${admin_username}/.ssh/authorized_keys
 - 'chown ${admin_username}:${admin_username} /home/${admin_username}/.ssh/id_rsa*'
 - chmod 400 /home/${admin_username}/.ssh/id_rsa
 - sed -i -E "s/^#Allow 10.0.0.0\/8.*$/Allow 10.0.0.0\/8/" /etc/tinyproxy/tinyproxy.conf
 - systemctl restart tinyproxy
 - bash -c 'cd /tmp && wget -q https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz && tar -zxf openshift-client-linux.tar.gz && sudo mv oc kubectl /usr/local/bin/ && rm openshift-client-linux.tar.gz'
 - tmpdir=$(mktemp -d) && curl -sL "https://api.github.com/repos/derailed/k9s/releases/latest" | jq -r '.assets[] | select(.browser_download_url | endswith("k9s_Linux_amd64.tar.gz")) | .browser_download_url' | xargs curl -sSL | tar -xz -C "$tmpdir" k9s && sudo mv "$tmpdir/k9s" /usr/local/bin/k9s && rm -rf "$tmpdir"
 # XRDP setup
 - systemctl enable xrdp
 # has to happen for each user, so we do it here in cloud-init for the default admin user
 - echo xfce4-session >/home/ubuntu/.xsession
 - chown ubuntu:ubuntu /home/ubuntu/.xsession
 - systemctl restart xrdp
%{ if length(vars) > 0 && vars[0] != "" }
 # Backup setup using resticprofile
 - bash -c 'CURRENT_VERSION="$(curl -sL https://api.github.com/repos/restic/restic/releases/latest | jq -r .tag_name)" && curl -sSL "https://github.com/restic/restic/releases/download/$${CURRENT_VERSION}/restic_$${CURRENT_VERSION:1}_linux_amd64.bz2" | bzip2 -d > /usr/local/bin/restic && chmod a+x /usr/local/bin/restic'
 - cd /usr/local && curl -sfL https://raw.githubusercontent.com/creativeprojects/resticprofile/master/install.sh | sh
 - resticprofile --config /etc/resticprofile/profiles.yaml schedule --all
 #TODO restore to other location then rsync
 - resticprofile --config /etc/resticprofile/profiles.yaml restore latest --target /
%{ endif }
