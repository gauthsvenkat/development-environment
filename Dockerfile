# First build stage: build neovim from source
FROM debian:stable-slim as neovim-builder

# Ignore apt --no-install-recommends warning
# hadolint ignore=DL3015
RUN apt-get update && apt-get install -y \
    ninja-build gettext cmake unzip curl git

RUN git clone --depth 1 --branch stable https://github.com/neovim/neovim
WORKDIR /neovim
RUN make CMAKE_BUILD_TYPE=Release && \
    make install

# Second build stage: copy (built) neovim from first build stage
FROM debian:stable-slim as final
COPY --from=neovim-builder /usr/local/ /usr/local/

# Install base dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    sudo \
    zsh \
    git \
    curl \
    ca-certificates \
    make \
    cmake \
    gcc \
    g++ \
    libc6-dev \
    ripgrep \
    fd-find \
    && rm -rf /var/lib/apt/lists/*

# Create user and give it sudo access without password
RUN useradd -m dev && \
    echo 'dev ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
USER dev

# Install rustup (needed for sniprun)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Install personal configs for neovim and zsh
# Note that the plugins are not installed at this stage.
RUN git clone https://github.com/gauthsvenkat/nvim.git /home/dev/.config/nvim && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
