FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

USER root
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl -sS https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && \
        apt-get -y install --no-install-recommends golang-go ruby shellcheck python3-pip python3-dev ansible-lint \
        apt-transport-https ca-certificates gnupg google-cloud-cli google-cloud-sdk-minikube google-cloud-sdk-gke-gcloud-auth-plugin google-cloud-cli-kpt kubectl terraform \
        openjdk-17-jdk openjdk-17-source openjdk-21-jdk openjdk-21-source && \
    gem install mdl

USER vscode
RUN echo 'PATH="$HOME/.local/bin:$HOME/bin:$PATH"' >> ~/.bashrc
RUN python3 -m pip install cpplint pre-commit ansible kubernetes-validate ansible-lint requests pylint pytest --no-cache-dir --upgrade --break-system-packages --user
RUN go install mvdan.cc/sh/v3/cmd/shfmt@latest
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
RUN curl -s "https://get.sdkman.io" | bash
RUN bash -ic "sdk i java 17-openjdk /usr/lib/jvm/java-17-openjdk-amd64;\
            sdk i java 21-openjdk /usr/lib/jvm/java-21-openjdk-amd64;\
            sdk d java 21-openjdk;\
            sdk i maven;\
            sdk i groovy;\
            sdk i scala;"
