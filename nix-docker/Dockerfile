FROM ubuntu:24.04

# Install dependencies for Nix
RUN apt-get update && apt-get install -y \
    curl \
    xz-utils \
    sudo \
    git \
    locales \
    socat \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8

# Create dev user with home directory
RUN useradd -m -s /bin/bash -d /home/dev dev \
    && echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER dev
WORKDIR /home/dev
ENV USER=dev

RUN

# Install Nix (single-user mode)
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

# Make Nix available in subsequent RUN commands
ENV PATH="/home/dev/.nix-profile/bin:/nix/var/nix/profiles/default/bin:${PATH}"

# Enable flakes
RUN mkdir -p /home/dev/.config/nix \
    &&  mkdir /home/dev/workspace \
    && mkdir -p /home/dev/.local/share/zellij \
    && echo "experimental-features = nix-command flakes" > /home/dev/.config/nix/nix.conf

# Initialize home-manager with flakes, then replace with our config
RUN nix run home-manager/master -- init --switch

# Replace the default home-manager config with ours
COPY --chown=dev:dev nix_home_manager/ /home/dev/.config/home-manager/
COPY --chown=dev:dev claude.json /home/dev/.claude.json
COPY --chown=dev:dev /Users/bedwards/.local/share/zellij/tokens.db /home/dev/.local/share/zellij/tokens.db
COPY --chown=dev:dev /Users/bedwards/.config/git/ignore /home/dev/.config/git/ignore

# Init a fresh git repo so Nix flake fetcher doesn't follow stale submodule refs
RUN cd /home/dev/.config/home-manager && rm -rf .git

# Run home-manager switch with the docker flake target
RUN nix run home-manager/master -- switch --flake /home/dev/.config/home-manager#docker

# Install claude-code to a writable prefix (Nix store is read-only)
RUN mkdir -p /home/dev/.npm-global \
    && npm config set prefix /home/dev/.npm-global \
    && npm install -g @anthropic-ai/claude-code \
    && npm install -g @beads/bd \
    && claude install \
    && git config --global user.name "Brian Edwards" \
    && git config --global user.email "brian@edwardstx.us"
ENV PATH="/home/dev/.npm-global/bin:${PATH}"

COPY --chown=dev:dev entrypoint.sh /home/dev/entrypoint.sh
RUN chmod +x /home/dev/entrypoint.sh

EXPOSE 9999

ENTRYPOINT ["/home/dev/entrypoint.sh"]
