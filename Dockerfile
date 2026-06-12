FROM ubuntu:24.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

ARG RUST_TOOLCHAIN="1.96"
ARG DIOXUS_CLI_VERSION="0.7"

# Install Rust globally into /opt/rust.
# Do NOT set CARGO_HOME globally at runtime; users should get their own writable
# cargo cache under $HOME/.cargo or another location they set.
ENV RUSTUP_HOME=/opt/rust/rustup
ENV PATH=/opt/rust/cargo/bin:${PATH}

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    bash \
    file \
    unzip \
    xz-utils \
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
    libpq-dev \
    \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/rust/cargo /opt/rust/rustup /workspace \
    && chmod -R a+rX /opt/rust \
    && chmod 1777 /workspace

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup-init.sh \
    && CARGO_HOME=/opt/rust/cargo \
       RUSTUP_HOME=/opt/rust/rustup \
       sh /tmp/rustup-init.sh \
         -y \
         --no-modify-path \
         --profile default \
         --default-toolchain "${RUST_TOOLCHAIN}" \
    && rm /tmp/rustup-init.sh

RUN CARGO_HOME=/opt/rust/cargo \
    RUSTUP_HOME=/opt/rust/rustup \
    rustup target add wasm32-unknown-unknown --toolchain "${RUST_TOOLCHAIN}" \
    && CARGO_HOME=/opt/rust/cargo \
       RUSTUP_HOME=/opt/rust/rustup \
       cargo install dioxus-cli --version "${DIOXUS_CLI_VERSION}" --locked \
    && chmod -R a+rX /opt/rust \
    && rustc --version \
    && cargo --version \
    && dx --version

WORKDIR /workspace

EXPOSE 8080
EXPOSE 3000

CMD ["bash"]
