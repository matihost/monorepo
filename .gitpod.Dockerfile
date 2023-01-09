# To build & test: docker build -f .gitpod.Dockerfile -t gitpod-dockerfile-test . &&  docker run -it gitpod-dockerfile-test bash
ARG JDK_FLAVOR=17.0.5-tem
FROM gitpod/workspace-full:latest


USER root
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl -sS https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list

RUN install-packages ruby shellcheck python3-dev tox ansible-lint \
        apt-transport-https ca-certificates gnupg google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin google-cloud-cli-kpt kubectl terraform && \
    gem install mdl

USER gitpod
RUN go install mvdan.cc/sh/v3/cmd/shfmt@latest
RUN python3 -m pip install pre-commit ansible kubernetes-validate ansible-lint requests pylint pytest pipenv pipenv-setup yamllint --user
RUN bash -c ". /home/gitpod/.sdkman/bin/sdkman-init.sh && sdk i java ${JDK_FLAVOR} && sdk d java ${JDK_FLAVOR}"
