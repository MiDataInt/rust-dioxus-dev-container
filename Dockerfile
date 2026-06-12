FROM ubuntu:24.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

# Optional: pin Dioxus CLI to match your app's Dioxus version.
# Example:
#   docker build --build-arg DIOXUS_CLI_VERSION=0.6.3 -t dioxus-web-dev .
ARG DIOXUS_CLI_VERSION=""

# Create a non-root user so mounted project files are not owned by root.
ARG USERNAME=dioxus
ARG USER_UID=1000
ARG USER_GID=1000

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    bash \
    file \
    unzip \
    xz-utils \
    sudo \
    \
    build-essential \
    make \
    pkg-config \
    cmake \
    ninja-build \
    \
    clang \
    lld \
    llvm \
    libclang-dev \
    \
    protobuf-compiler \
    \
    libssl-dev \
    zlib1g-dev \
    libsqlite3-dev \
    \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" -m "${USERNAME}" \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" \
    && chmod 0440 "/etc/sudoers.d/${USERNAME}"

USER ${USERNAME}

ENV RUSTUP_HOME=/home/${USERNAME}/.rustup
ENV CARGO_HOME=/home/${USERNAME}/.cargo
ENV PATH=/home/${USERNAME}/.cargo/bin:${PATH}

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --profile default --default-toolchain stable \
    && rustup target add wasm32-unknown-unknown \
    && if [[ -n "${DIOXUS_CLI_VERSION}" ]]; then \
         cargo install dioxus-cli --version "${DIOXUS_CLI_VERSION}" --locked; \
       else \
         cargo install dioxus-cli --locked; \
       fi \
    && rustc --version \
    && cargo --version \
    && dx --version

WORKDIR /workspace

# Common Dioxus dev server ports.
EXPOSE 8080
EXPOSE 3000

CMD ["bash"]
