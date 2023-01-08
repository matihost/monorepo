#  docker build -f .gitpod.Dockerfile -t gitpod-dockerfile-test . &&  docker run -it gitpod-dockerfile-test bash
FROM gitpod/workspace-full:latest

USER root
RUN go install mvdan.cc/sh/v3/cmd/shfmt@latest
RUN install-packages ruby shellcheck python3-dev \
    && gem install mdl


USER gitpod
RUN go install mvdan.cc/sh/v3/cmd/shfmt@latest \
    && pip3 install pre-commit ansible --user
RUN bash -c ". /home/gitpod/.sdkman/bin/sdkman-init.sh && sdk i java 17.0.5-tem && sdk d java 17.0.5-tem"
