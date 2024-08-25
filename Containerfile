FROM ghcr.io/ublue-os/arch-distrobox as arch-distrobox

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="Personal asen23 distrobox" \
      maintainer="asen23"

FROM arch-distrobox AS arch-work-distrobox

# Install packages
RUN pacman -S \
        zsh \
        chezmoi \
        --noconfirm

# Change default shell
RUN sed -i '/^SHELL/s/\/usr\/bin\/bash/\/bin\/zsh/' /etc/default/useradd

# Create build user
RUN useradd -m --shell=/bin/bash build && usermod -L build && \
    echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install AUR packages
USER build
WORKDIR /home/build
RUN paru -S \
      aur/visual-studio-code-bin \
      --noconfirm
USER root
WORKDIR /

# Cleanup
RUN userdel -r build && \
    rm -drf /home/build && \
    sed -i '/build ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    sed -i '/root ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    rm -rf \
      /tmp/* \
      /var/cache/pacman/pkg/*
