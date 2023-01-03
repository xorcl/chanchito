FROM python:3.9-slim-buster

# Ensures our console output looks familiar and is not buffered by Docker, which we don’t want.
ENV PYTHONUNBUFFERED 1
# Will not get prompted for input
ARG DEBIAN_FRONTEND=noninteractive

# Update repos and upgrade packages
RUN apt-get update -qq
RUN apt-get upgrade -yq

# Install apt-utils so debian will not complain about delaying configurations
RUN apt-get install -yq --no-install-recommends apt-utils gettext

# Required for i18n
# RUN apt-get install -yq gettext

# Upgrade pip
RUN pip install --no-cache-dir --upgrade pip

#Set working directory
RUN mkdir /build
RUN pip install poetry
RUN poetry config virtualenvs.create false

# Create non root user and all folders in which he'll have to write
RUN adduser --system --group api

# Copy poetry files first and install dependencies
# This is done earlier to avoid repeating when building the image
RUN mkdir /src
COPY ./src/poetry.lock /src/poetry.lock
COPY ./src/pyproject.toml /src/pyproject.toml
WORKDIR /src
RUN poetry install

# Finally copy the src and do everything src-related
COPY ./src /src
COPY ./build /build

# Expose Gunicorn Port
EXPOSE 8080

ENTRYPOINT [ "/build/entrypoint.sh" ]
