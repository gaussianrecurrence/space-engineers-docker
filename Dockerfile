FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Enable 32-bit support and install dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
        curl \
        wget \
        ca-certificates \
        lib32gcc-s1 \
        lib32stdc++6 \
        libc6-i386 \
        libsdl2-2.0-0 \
        libicu72 \
        tar \
        gzip \
        cron \
        bash \
    && rm -rf /var/lib/apt/lists/*

# Install SteamCMD
RUN useradd -m -s /bin/bash steam && \
    mkdir -p /home/steam/steamcmd && \
    cd /home/steam/steamcmd && \
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xvzf steamcmd_linux.tar.gz && \
    chown -R steam:steam /home/steam

USER steam
WORKDIR /home/steam

# Create directories
RUN mkdir -p \
    /home/steam/spaceengineers \
    /home/steam/instance \
    /home/steam/backups

COPY --chown=steam:steam docker-entrypoint.sh /home/steam/docker-entrypoint.sh
RUN chmod +x /home/steam/docker-entrypoint.sh

EXPOSE 27016/udp 27016/tcp

ENTRYPOINT ["/home/steam/docker-entrypoint.sh"]
