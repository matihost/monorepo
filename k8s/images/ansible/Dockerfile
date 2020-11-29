FROM jfloff/alpine-python:latest
RUN pip3 install --upgrade pip && \
  adduser -D -G root -u 1000 default
USER default
ENV PATH=${PATH}:/home/default/.local/bin
RUN pip3 install ansible openshift pipenv --user --upgrade && \
  ansible-galaxy collection install community.kubernetes
