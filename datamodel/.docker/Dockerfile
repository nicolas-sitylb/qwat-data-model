# requires buildkit (default from docker engine 23.0)

ARG POSTGIS_IMAGE=postgis/postgis:16-3.5
ARG DEBIAN_FRONTEND=noninteractive

# arm builds are not available with 3.2
#FROM imresamu/postgis-arm64:14-3.2 AS base-arm64
FROM "${POSTGIS_IMAGE}" AS base-arm64

FROM "${POSTGIS_IMAGE}" AS base-amd64

FROM base-${BUILDARCH} as common

ARG AUTO_INIT=True
ARG RUN_TEST=False
ARG PSYCOPG_VERSION=3
ARG DEBIAN_FRONTEND

# System deps (bc + exiftool for testing)
RUN \
  apt-get update \
  && apt-get install -y --no-install-recommends \
     python3 \
     python3-pip \
     python3-venv \
     libpq-dev \
     wget \
     exiftool \
     bc \
  && apt-get autoclean \
  && apt-get autoremove --purge

# Add source
ADD ./datamodel /src/datamodel
WORKDIR /src

# Python deps
ENV VIRTUAL_ENV="/opt/venv"
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

RUN python3 -m venv "${VIRTUAL_ENV}" \
  && pip install -r datamodel/requirements/requirements.txt \
  && pip install -r datamodel/requirements/requirements-psycopg${PSYCOPG_VERSION}.txt \
  && if [ "${RUN_TEST}" = "True" ]; then \
      pip install --no-cache-dir -r datamodel/requirements/requirements-test.txt; \
    fi

# Configure the postgresql connection
RUN cp ./datamodel/conf/pg_service.conf /etc/postgresql-common/pg_service.conf \
  && chmod +x /src/datamodel/.docker/init_db.sh

ENV PATH="/src/datamodel/.docker:${PATH}"

# Execute the main script on database initialization (20_* to be after postgis init)
RUN if [ "${AUTO_INIT}" = "True" ]; then \
      ln -s /src/datamodel/.docker/init_db.sh \
            /docker-entrypoint-initdb.d/20_init_db.sh; \
    fi

ENV PGSERVICE=pg_qwat

ENV PYTEST_ADDOPTS="--color=yes"
