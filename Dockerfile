FROM debian:stable-slim

# Install base dependencies
RUN apt update && apt install -y \
    sudo \
    curl \
    wget \
    git \
    zsh \
    ninja-build \
    gettext \
    unzip \
    gcc \
    make \
    cmake \
    nodejs \
    npm \
    python3 \
    python3-pip \
    python3-neovim \
    ripgrep \
    fd-find \
    && rm -rf /var/lib/apt/lists/*

# Install Neovim from source
RUN git clone -b stable https://github.com/neovim/neovim && \
    cd neovim && \
    make CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make install && \
    cd .. && \
    rm -rf neovim

# Create user and give it sudo access without password
RUN useradd -m dev && \
    echo 'dev ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
USER dev

# Install rustup (needed for some neovim plugins)
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Setup Oh My Zsh and personal neovim config
RUN sh -c "$(wget --progress=dot:giga https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" --unattended && \
    git clone https://github.com/gauthsvenkat/nvim.git /home/dev/.config/nvim && \
    nvim -c "q"
