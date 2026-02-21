FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV STEAMCMD_DIR=/home/steam/steamcmd
ENV SE_DIR=/home/steam/spaceengineers
ENV INSTANCE_DIR=/home/steam/instance
ENV BACKUP_DIR=/home/steam/backups
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
        cabextract \
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
RUN cd ${STEAMCMD_DIR} && \
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xvzf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz

# -------------------------------
#  4️⃣ CInstall winetricks
# -------------------------------
RUN curl -L https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks > /usr/local/bin/winetricks && \
    chmod +x /usr/local/bin/winetricks

ENV WINEARCH=win64
ENV WINEDEBUG=-all
ENV WINEPREFIX=/home/steam/wine

USER steam
RUN Xvfb :5 -screen 0 1024x768x16 & \
    env WINEDLLOVERRIDES="mscoree=d" wineboot --init /nogui && \
    winetricks corefonts && \
    winetricks sound=disabled && \
    env DISPLAY=:5.0 winetricks -q vcrun2019 && \
    env DISPLAY=:5.0 winetricks -q --force dotnet48
USER root

# -------------------------------
# 5️⃣ Copy entrypoint
# -------------------------------
COPY --chown=steam:steam docker-entrypoint.sh /home/steam/docker-entrypoint.sh
RUN chmod +x /home/steam/docker-entrypoint.sh

# -------------------------------
# 6️⃣ Security: Host user mapping
# -------------------------------
ENV PUID=1000
ENV PGID=1000

ENTRYPOINT ["/home/steam/docker-entrypoint.sh"]

EXPOSE 27016/udp 27016/tcp
