# Base Image
FROM ubuntu:22.04

# Set Github Runner Version
ARG RUNNER_VERSION="2.312.0"
ARG DEBIAN_FRONTEND=noninteractive

# Labels for the image
LABEL Author="Christian Schou"
LABEL Email="chsc@christian-schou.dk"
LABEL GitHub="https://github.com/Christian-Schou"
LABEL BaseImage="ubuntu:22.04"
LABEL RunnerVersion=${RUNNER_VERSION}

# Update the base packages + add a non-sudo docker user
RUN apt update -y && apt upgrade -y && useradd -m docker

# Install the packages and dependencies along with jq so we can parse JSON (add additional packages as necessary)
RUN apt install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

# Download and extract the runner based on the version provided
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Install extra dependencies for the runner
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# Copy the startup script
COPY scripts/startup.sh startup.sh

# Make the startup script executable
RUN chmod +x startup.sh

# Set the current user to "docker". This will make all other subsequent commands run as the docker user
USER docker

# Run startup.sh when the container is starting
ENTRYPOINT ["./startup.sh"]
