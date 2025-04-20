FROM python:3.13
# TODO remove -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true and --allow-unauthenticated when
#
# Kaniko started showing errors, Kaniko is adding own /etc/apt/ sources as well if image is based on Ubuntu
# .. (which should not)
#
# Get:1 http://deb.debian.org/debian bullseye InRelease [116 kB]
# Get:2 http://deb.debian.org/debian-security bullseye-security InRelease [48.4 kB]
# Get:3 http://deb.debian.org/debian bullseye-updates InRelease [44.1 kB]
# Err:1 http://deb.debian.org/debian bullseye InRelease
#   Unknown error executing apt-key
# Err:2 http://deb.debian.org/debian-security bullseye-security InRelease
#   Unknown error executing apt-key
# Err:3 http://deb.debian.org/debian bullseye-updates InRelease
#   Unknown error executing apt-key
# Reading package lists...
# W: GPG error: http://deb.debian.org/debian bullseye InRelease: Unknown error executing apt-key
# E: The repository 'http://deb.debian.org/debian bullseye InRelease' is not signed.
# W: GPG error: http://deb.debian.org/debian-security bullseye-security InRelease: Unknown error executing apt-key
# E: The repository 'http://deb.debian.org/debian-security bullseye-security InRelease' is not signed.
# W: GPG error: http://deb.debian.org/debian bullseye-updates InRelease: Unknown error executing apt-key
# E: The repository 'http://deb.debian.org/debian bullseye-updates InRelease' is not signed.
# error building image: error building stage: failed to execute command: waiting for process to exit: exit status 100
RUN pip3 install --no-cache-dir --upgrade pip \
  && adduser --uid 1000 --disabled-password --ingroup root default
RUN apt -y -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true update \
  && apt -y --allow-unauthenticated install python3-venv \
  && rm -rf /var/lib/apt/lists/*
USER default
# in case use site packages are available
ENV PATH=${PATH}:/home/default/.local/bin
RUN pip3 install ansible openshift pipenv tox pylint pytest poetry ruff pre-commit ansible-lint --no-cache-dir --user --upgrade && \
  ansible-galaxy collection install community.kubernetes
# for python libraries needed own virtual env
ENV PATH=${PATH}:/home/default/.venv/user/bin
RUN python3 -m venv /home/default/.venv/user
