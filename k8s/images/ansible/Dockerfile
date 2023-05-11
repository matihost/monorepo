FROM python:3.11
RUN pip3 install --no-cache-dir --upgrade pip && \
  adduser --uid 1000 --disabled-password --ingroup root default
RUN apt-get update && apt-get install -y python3-venv
USER default
# in case use site packages are available
ENV PATH=${PATH}:/home/default/.local/bin
RUN pip3 install ansible openshift pipenv tox pylint pytest pre-commit ansible-lint --no-cache-dir --user --upgrade && \
  ansible-galaxy collection install community.kubernetes
# for python libraries needed own virtual env
ENV PATH=${PATH}:/home/default/.venv/user/bin
RUN python3 -m venv /home/default/.venv/user
