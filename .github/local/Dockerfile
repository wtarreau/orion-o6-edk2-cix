FROM debian:bookworm

# Cix's edk2-non-osi libraries enabled LTO,
# forcing us to use the custom gcc instead of crossbuild-essential-arm64.
RUN apt-get update && \
    apt-get full-upgrade --no-install-recommends -y \
        build-essential git curl \
        debhelper devscripts lintian dh-exec pandoc shellcheck \
        acpica-tools uuid-dev nasm && \
    adduser --gecos runner --disabled-password runner && \
    curl -L https://developer.arm.com/-/media/Files/downloads/gnu-a/10.2-2020.11/binrel/gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf.tar.xz | \
    tar -xJC /opt && \
    rm -rf /var/lib/apt/lists/*
