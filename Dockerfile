FROM debian:stable-slim

# Install base dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    sudo \
    curl \
    git \
    zsh \
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

# Install Neovim system-wide
RUN curl -O https://github.com/neovim/neovim/releases/download/v0.9.4/nvim-linux64.tar.gz && \
    tar xzf nvim-linux64.tar.gz && \
    rm -if /usr/local/man && \
    cp -r nvim-linux64/* /usr/local/ && \
    rm -rf nvim-linux64 nvim-linux64.tar.gz

# Create user and give it sudo access without password
RUN useradd -m dev && \
    echo 'dev ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
USER dev

# Install rustup (needed for some neovim plugins)
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Setup Oh My Zsh and personal neovim config
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended && \
    git clone https://github.com/gauthsvenkat/nvim.git /home/dev/.config/nvim && \
    nvim -c "q"
