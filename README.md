# Personal development environment

## Prerequisites

- Docker installed on your machine.
- `make` command available in your terminal.

## Instructions

- Copy the contents of [Makefile](Makefile) locally.
- You might want to add extra options (eg.environment variables) to the docker run command like so.
  ```
  --volume /path/to/.ssh:/home/dev/.ssh:ro \
  --publish 8050:8050 \
  --env DEXTER_API_PRODUCTION_USER="<your_username>" \
  --env DEXTER_API_PRODUCTION_PASSWORD="<your_password>" \
  --env POETRY_HTTP_BASIC_GITLAB_USERNAME="__token__" \
  --env POETRY_HTTP_BASIC_GITLAB_PASSWORD="<your_token>" \
  ```
- Run with `make`.

## Usage

- `make run`: If the Docker container doesn't exist, this command creates it and enters it. If the container exists, this command starts and enters it.

- `make clean`: This command removes the Docker container.
