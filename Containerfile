FROM quay.io/fedora/fedora-iot:44

RUN --mount=type=cache,destination=/var/cache \
    --mount=type=cache,destination=/var/lib/dnf \
    --mount=type=tmpfs,destination=/var/log \
    dnf5 -y config-manager setopt 'fedora-cisco-openh264*'.enabled=0

RUN --mount=type=cache,destination=/var/cache \
    --mount=type=cache,destination=/var/lib/dnf \
    --mount=type=tmpfs,destination=/var/log \
    --mount=type=tmpfs,destination=/run \
    curl -fL https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o /etc/yum.repos.d/tailscale.repo && \
    sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/tailscale.repo

RUN rm -r /opt && mkdir -p /var/opt && ln -rs /var/opt /opt && \
    rm -r /usr/local && mkdir -p /var/usrlocal && ln -rs /var/usrlocal /usr/local && \
    setsebool -P container_use_dri_devices=1 container_use_devices=1

COPY ./build_files/packages /tmp/packages
RUN --mount=type=cache,destination=/var/cache \
    --mount=type=cache,destination=/var/lib/dnf \
    --mount=type=tmpfs,destination=/var/log \
    --mount=type=tmpfs,destination=/run \
    dnf5 -y config-manager setopt keepcache=True && \
    dnf -y --setopt='tailscale*'.enabled=1 install tailscale && \
    dnf -y --setopt=install_weak_deps=False install $(cat /tmp/packages) && rm /tmp/packages && \
    dnf5 -y config-manager setopt keepcache=False

COPY --from=ghcr.io/ublue-os/brew:latest@sha256:b3425199be750618562faad58b9944629805e0e1cac8bf60b18d6bc132a56909 /system_files /
RUN --mount=type=cache,destination=/var/cache \
    --mount=type=tmpfs,destination=/var/log \
    systemctl preset brew-setup.service && \
    systemctl preset brew-update.timer && \
    systemctl preset brew-upgrade.timer

RUN rm /etc/os-release && cp /usr/lib/os-release /etc/os-release

# renovate: datasource=github-releases depName=k3s-io/k3s versioning=regex:^v(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)\+k3s(?<build>\d+)$
ARG INSTALL_K3S_VERSION=v1.37.1+k3s1

RUN --mount=type=cache,destination=/var/cache \
    --mount=type=cache,destination=/var/lib/dnf \
    --mount=type=tmpfs,destination=/var/log \
    --mount=type=tmpfs,destination=/run \
  dnf5 -y config-manager setopt keepcache=True && \
  curl -sfL https://get.k3s.io | \
  INSTALL_K3S_SKIP_ENABLE=true \
  INSTALL_K3S_SKIP_START=true \
  INSTALL_K3S_SYMLINK=force \
  INSTALL_K3S_BIN_DIR=/usr/bin \
  INSTALL_K3S_SELINUX_WARN=true \
  sh - && \
  dnf5 -y config-manager setopt keepcache=False rancher-k3s-common-stable.enabled=0

COPY ./system_files/ /

RUN bootc container lint --no-truncate
