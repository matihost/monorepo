FROM python:3.8
RUN pip3 install --no-cache-dir --upgrade pip && \
  adduser --uid 1000 --disabled-password --ingroup root default
USER default
ENV PATH=${PATH}:/home/default/.local/bin
RUN pip3 install ansible openshift pipenv tox pylint pytest pre-commit ansible-lint --no-cache-dir --user --upgrade && \
  ansible-galaxy collection install community.kubernetes
