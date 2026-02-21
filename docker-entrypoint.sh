#!/bin/bash
set -e

# -------------------------------
# 1️⃣ Host user mapping
# -------------------------------
PUID=${PUID:-1000}
PGID=${PGID:-1000}

groupmod -g ${PGID} steam
usermod -u ${PUID} -g ${PGID} steam

# -------------------------------
# 2️⃣ Directories
# -------------------------------

export HOME=/home/steam
mkdir -p ${SE_DIR} ${INSTANCE_DIR} ${BACKUP_DIR}
chown -R ${PUID}:${PGID} /tmp/wine-*
chown -R ${PUID}:${PGID} ${HOME}

STEAMCMD="$STEAMCMD_DIR/steamcmd.sh"

# -------------------------------
# 3️⃣ SteamCMD Update
# -------------------------------
LOGIN_CMD="+login anonymous"
if [ -n "${STEAM_USER}" ] && [ -n "${STEAM_PASS}" ]; then
    LOGIN_CMD="+login ${STEAM_USER} ${STEAM_PASS}"
fi

echo "==== Updating Space Engineers (Windows version) ===="
gosu steam ${STEAMCMD} +force_install_dir ${SE_DIR} ${LOGIN_CMD} +app_update ${APP_ID} validate +quit

# -------------------------------
# 4️⃣ Backup loop
# -------------------------------
BACKUP_INTERVAL=${BACKUP_INTERVAL:-3600}
BACKUP_RETENTION=${BACKUP_RETENTION:-5}

backup_loop() {
    while true; do
        sleep ${BACKUP_INTERVAL}
        TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
        BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.tar.gz"
        echo "==== Creating backup ${BACKUP_FILE} ===="
        tar -czf "${BACKUP_FILE}" -C "${INSTANCE_DIR}" .
        ls -1t "${BACKUP_DIR}"/backup_*.tar.gz | tail -n +$((BACKUP_RETENTION+1)) | xargs -r rm --
        echo "==== Backup complete ===="
    done
}

backup_loop &

# -------------------------------
# 5️⃣ Start Space Engineers via Proton
# -------------------------------
echo "==== Starting Space Engineers Dedicated Server via Proton ===="

export INTERNAL_INSTANCE_DIR="Z:\\home\\steam\\instance"

# Run using Proton / Wine
exec gosu steam wine SpaceEngineersDedicated.exe \
    -console \
    -path "${INTERNAL_INSTANCE_DIR}" \
    -config "${INTERNAL_INSTANCE_DIR}\\SpaceEngineers-Dedicated.cfg"
