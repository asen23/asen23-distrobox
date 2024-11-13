FROM ghcr.io/ublue-os/fedora-toolbox as base

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

# remove atuin bash integration to avoid error message
RUN rm /etc/profile.d/atuin.sh

COPY ./.nobrew /etc/skel/.nobrew

RUN rm /base-packages

FROM base as work

COPY ./packages.work /work-packages

COPY ./repo/vscode.repo /etc/yum.repos.d/vscode.repo

RUN dnf -y upgrade && \
    dnf -y install $(<work-packages) && \
    dnf clean all

RUN rm /work-packages

FROM ghcr.io/ublue-os/fedora-toolbox as app

COPY ./packages.app /app-packages

RUN dnf -y upgrade && \
    dnf -y install $(<app-packages) && \
    dnf clean all

RUN rm /app-packages
