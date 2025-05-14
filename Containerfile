FROM ghcr.io/ublue-os/fedora-toolbox@sha256:c55988b89380c5b34d317d6969942d2212b689afceac952f90aae0916fa8723e as base

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="Personal asen23 distrobox" \
      maintainer="asen23"

COPY ./packages.base /base-packages

COPY ./init.sh /etc/profile.d/init.sh

RUN dnf copr enable atim/starship -y
RUN dnf copr enable sramanujam/atuin -y

RUN dnf -y upgrade && \
    dnf -y install $(<base-packages) && \
    dnf clean all

# install lazygit
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*') && \
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
    tar xf lazygit.tar.gz lazygit && \
    install lazygit -D /usr/bin/lazygit && \
    rm -f lazygit.tar.gz lazygit

# install zellij
RUN ZELLIJ_VERSION=$(curl -s "https://api.github.com/repos/zellij-org/zellij/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*') && \
    curl -Lo zellij.tar.gz "https://github.com/zellij-org/zellij/releases/download/v${ZELLIJ_VERSION}/zellij-x86_64-unknown-linux-musl.tar.gz" && \
    tar xf zellij.tar.gz zellij && \
    install zellij -D /usr/bin/zellij && \
    rm -f zellij.tar.gz zellij

# install eza
RUN EZA_VERSION=$(curl -s "https://api.github.com/repos/eza-community/eza/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*') && \
    curl -Lo eza.tar.gz "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz" && \
    tar xf eza.tar.gz ./eza && \
    install eza -D /usr/bin/eza && \
    rm -f eza.tar.gz eza

COPY ./.nobrew /etc/skel/.nobrew

RUN rm /base-packages

FROM base as work

COPY ./packages.work /work-packages

COPY ./repo/vscode.repo /etc/yum.repos.d/vscode.repo

RUN dnf -y upgrade && \
    dnf -y install $(<work-packages) && \
    dnf -y install java-17-openjdk java-17-openjdk-devel --releasever=41 && \
    dnf -y install cracklib-dicts glibc-common && \
    dnf clean all

RUN rm /work-packages
