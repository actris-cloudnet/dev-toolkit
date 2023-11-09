FROM python:3.10-bullseye
RUN apt-get update \
  && apt-get install -y --no-install-recommends less \
  && rm -rf /var/lib/apt/lists/* \
  && pip install --no-cache-dir pgcli
ENTRYPOINT ["pgcli"]
