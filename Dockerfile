ARG UBUNTU_VERSION=18.04
FROM ubuntu:${UBUNTU_VERSION}

# Requirements
RUN apt-get update && \
    apt-get install -y git meson gcc jose pkg-config libjose-dev libjose0 cmake libcryptsetup-dev clang g++ luksmeta && \
    apt-get install -y tang curl initramfs-tools libpwquality-tools libjansson4 libssl1.1 vim libluksmeta0 libluksmeta-dev && \
    apt-get install -y ruby ruby-dev rubygems build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* && \
    gem install --no-document fpm


# Actual compiling
RUN mkdir -p /tmp && \
    cd /tmp && \
    git clone https://github.com/latchset/clevis.git && \
    cd /tmp/clevis && \
    git checkout v12 && \
    meson build && \
    ninja -C build -j$(nproc) && \
    ninja -C build install && \
    # If we use the build prefix the initramfs module doesn't work so we have to move everything by hand.
    # To be clear: Not only do they not move, they actually contain the prefix at runtime so just don't.
    mkdir -p /build/usr/local/bin && \
    mkdir -p /build/usr/share/initramfs-tools/hooks && \
    mkdir -p /build/usr/share/initramfs-tools/scripts/local-bottom && \
    mkdir -p /build/usr/share/initramfs-tools/scripts/local-top && \
    cp /usr/local/bin/clevis-decrypt-sss /build/usr/local/bin/. && \
    cp /usr/local/bin/clevis-encrypt-sss /build/usr/local/bin/. && \
    cp /usr/share/initramfs-tools/hooks/clevis /build/usr/share/initramfs-tools/hooks/. && \
    cp /usr/share/initramfs-tools/scripts/local-top/clevis /build/usr/share/initramfs-tools/scripts/local-top/. && \
    cp /usr/share/initramfs-tools/scripts/local-bottom/clevis /build/usr/share/initramfs-tools/scripts/local-bottom/. && \
    cp /usr/local/bin/clevis-luks-unbind /build/usr/local/bin/. && \
    cp /usr/local/bin/clevis-luks-unlock /build/usr/local/bin/. && \
    cp /usr/local/bin/clevis-luks-bind /build/usr/local/bin/. && \
    cp /usr/local/bin/clevis-decrypt-tang /build/usr/local/bin/. && \
    cp /usr/local/bin/clevis-encrypt-tang /build/usr/local/bin/. && \
    cp /usr/local/bin/clevis-decrypt /build/usr/local/bin/. && \
    cp /usr/local/bin/clevis /build/usr/local/bin/. && \
    echo "DONE"

# Our patch
COPY clevis-local-top.sh /build/usr/share/initramfs-tools/scripts/local-top/clevis

RUN chmod 755 /build/usr/share/initramfs-tools/scripts/local-top/clevis

# Now to build a temporary debian package
RUN mkdir -p /out && \
    cd /out && \
    fpm \
    -s dir \
    -t deb \
    -n clevis \
    -v 12.0 \
    --iteration 0 \
    -m "<CSI>" \
    --vendor "CSI" \
    --description "automated encryption framework" \
    --provides clevis \
    --depends libc6 \
    --depends libjansson4 \
    --depends libjose0 \
    --depends libssl1.1 \
    --depends cracklib-runtime \
    --depends curl \
    --depends jose \
    --depends libpwquality-tools \
    --depends luksmeta \
    /build/=/


