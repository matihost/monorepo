FROM python:3.12-alpine
RUN apk add git
RUN pip3 install --no-cache-dir --upgrade pip && \
  adduser --uid 1000 --disabled-password --ingroup root default
USER default
ENV PATH=${PATH}:/home/default/.local/bin
COPY --chown=1000 . /app
WORKDIR /app
RUN pip3 install --user --force-reinstall .
ENTRYPOINT [ "exchange-rate-web" ]
