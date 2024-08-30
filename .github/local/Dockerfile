FROM debian:bookworm

RUN dpkg --add-architecture arm64 && \
    apt-get update && \
    apt-get full-upgrade --no-install-recommends -y \
        python3-markupsafe:arm64 python3-cffi-backend:arm64 equivs && \
    equivs-build /tmp/equivs-dummy.equivs && \
    apt-get full-upgrade --no-install-recommends -y \
        build-essential crossbuild-essential-arm64 git \
        debhelper devscripts lintian \
        abigail-tools debhelper-compat dh-python dh-sequence-dkms \
        libaio-dev:arm64 libblkid-dev:arm64 \
        libcurl4-openssl-dev:arm64 libelf-dev:arm64 libpam0g-dev:arm64 \
        libssl-dev:arm64 libtirpc-dev:arm64 libtool libudev-dev:arm64 \
        lsb-release po-debconf python3-all-dev:arm64 python3-cffi \
        python3-setuptools python3-sphinx uuid-dev:arm64 zlib1g-dev:arm64 \
        dkms /equivs-dummy_1.0_all.deb && \
    adduser --gecos runner --disabled-password runner && \
    rm -rf /var/lib/apt/lists/* /tmp/equivs-dummy.equivs /equivs-dummy_1.0_all.deb
