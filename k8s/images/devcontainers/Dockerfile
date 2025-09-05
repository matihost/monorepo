FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

USER root
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && \
        apt-get -y install --no-install-recommends software-properties-common build-essential libssl-dev libffi-dev python3-dev python3-pip gh git python3-ansible-runner

USER vscode
RUN echo 'PATH="$HOME/.local/bin:$HOME/bin:$PATH"' >> ~/.bashrc && export PATH="$HOME/.local/bin:$HOME/bin:$PATH" && \
    mkdir -p ~/src && cd ~/src && git clone https://github.com/matihost/monorepo.git && cd monorepo && \
    cd ansible/system && \
    ansible-galaxy collection install community.general
    # && \
    # ansible-playbook -i wsl.yml ubuntu-setup.yaml -v -e wsl=false && \
	# ansible-playbook update.yaml -v && \
	# ansible-playbook clean.yaml -v
