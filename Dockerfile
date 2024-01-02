# First build stage: build neovim from source
FROM debian:stable-slim as neovim-builder

# Ignore apt --no-install-recommends warning
# hadolint ignore=DL3015
RUN apt-get update && apt-get install -y \
    ninja-build gettext cmake unzip curl git

# Build neovim from source
RUN git clone --depth 1 --branch stable https://github.com/neovim/neovim
WORKDIR /neovim
RUN make CMAKE_BUILD_TYPE=Release && \
    make install

# Second build stage: everything else
FROM debian:stable-slim as final
# copy neovim binaries from previous build stage
COPY --from=neovim-builder /usr/local/ /usr/local/

# Install base dependencies
# Ignore delete apt-get cache warning cause we expect
# to run apt inside the container
# hadolint ignore=DL3009
RUN apt-get update && apt-get install --no-install-recommends -y \
    sudo \
    zsh \
    git \
    openssh-client \
    curl \
    ca-certificates \
    make \
    cmake \
    gcc \
    g++ \
    libc6-dev \
    python3-dev \
    python3-pip \
    python3-venv \
    python3-distutils \
    ripgrep \
    fd-find

# Create user and give it sudo access without password
RUN useradd -m dev && \
    echo 'dev ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
USER dev

# Install oh-my-zsh
# This will create a ~/.zshrc file
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended

# Install poetry
RUN curl -sSL https://install.python-poetry.org | python3 - && \
    # Add poetry to path
    echo "export PATH=$PATH:/home/dev/.local/bin" >> /home/dev/.zshrc

# Install rustup (needed for sniprun)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Install nvm (which installs node and npm) (needed for copilot)
ENV NVM_DIR=/home/dev/.nvm
# Ignore that hadolint can't find the file
# hadolint ignore=SC1091
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    # source nvm.sh to make nvm available in the current shell
    . $NVM_DIR/nvm.sh && \
    nvm install node && \
    # add nvm.sh to zshrc so nvm is available in every shell
    echo "source $NVM_DIR/nvm.sh" >> /home/dev/.zshrc

# Install personal configs for neovim and zsh
# Note that the plugins are not installed at this stage.
RUN git clone https://github.com/gauthsvenkat/nvim.git /home/dev/.config/nvim && \
    nvim -c ":q"

# Default entry to the container is zsh
CMD ["zsh"]
