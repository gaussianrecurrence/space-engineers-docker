FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV STEAMCMD_DIR=/home/steam/steamcmd
ENV SE_DIR=/home/steam/spaceengineers
ENV INSTANCE_DIR=/home/steam/instance
ENV BACKUP_DIR=/home/steam/backups
ENV PROTON_DIR=/home/steam/proton
ENV APP_ID=298740
ENV WORKSHOP_APP_ID=244850

# -------------------------------
# 1️⃣ Install Dependencies
# -------------------------------
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
        curl wget ca-certificates \
        lib32gcc-s1 lib32stdc++6 libc6-i386 \
        libsdl2-2.0-0 libicu72 \
        tar gzip bash cron \
        git unzip \
        wine64 wine32 \
        xvfb \
        sudo \
        gosu \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------
# 2️⃣ Create steam user
# -------------------------------
RUN useradd -m -s /bin/bash steam && \
    mkdir -p $STEAMCMD_DIR $SE_DIR $INSTANCE_DIR $BACKUP_DIR $PROTON_DIR && \
    chown -R steam:steam /home/steam

WORKDIR /home/steam

# -------------------------------
# 3️⃣ Install SteamCMD
# -------------------------------
RUN cd $STEAMCMD_DIR && \
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xvzf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz && \
    chown -R steam:steam $STEAMCMD_DIR

# -------------------------------
# 4️⃣ Copy entrypoint
# -------------------------------
COPY --chown=steam:steam docker-entrypoint.sh /home/steam/docker-entrypoint.sh
RUN chmod +x /home/steam/docker-entrypoint.sh

# -------------------------------
# 5️⃣ Security: Host user mapping
# -------------------------------
ENV PUID=1000
ENV PGID=1000

ENTRYPOINT ["/home/steam/docker-entrypoint.sh"]

EXPOSE 27016/udp 27016/tcp
