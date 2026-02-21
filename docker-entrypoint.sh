#!/bin/bash
set -e

# -------------------------------
# 1️⃣ Host user mapping
# -------------------------------
PUID=${PUID:-1000}
PGID=${PGID:-1000}
USER_NAME=svc_runner
GROUP_NAME=svc_runner

if ! getent group ${GROUP_NAME} >/dev/null 2>&1; then
    groupadd -g "$PGID" ${GROUP_NAME}
fi

if ! id -u ${USER_NAME} >/dev/null 2>&1; then
    useradd -u "$PUID" -g "$PGID" -m -s /bin/bash ${USER_NAME}
fi

export HOME=/home/steam

# -------------------------------
# 2️⃣ Directories
# -------------------------------
mkdir -p $SE_DIR $INSTANCE_DIR $BACKUP_DIR $PROTON_DIR
chown -R $PUID:$PGID $SE_DIR $INSTANCE_DIR $BACKUP_DIR $PROTON_DIR

STEAMCMD="$STEAMCMD_DIR/steamcmd.sh"

# -------------------------------
# 3️⃣ SteamCMD Update
# -------------------------------
LOGIN_CMD="+login anonymous"
if [ -n "$STEAM_USER" ] && [ -n "$STEAM_PASS" ]; then
    LOGIN_CMD="+login $STEAM_USER $STEAM_PASS"
fi

echo "==== Updating Space Engineers (Windows version) ===="
gosu $USER_NAME $STEAMCMD +force_install_dir $SE_DIR $LOGIN_CMD +app_update $APP_ID validate +quit

# -------------------------------
# 4️⃣ Backup loop
# -------------------------------
BACKUP_INTERVAL=${BACKUP_INTERVAL:-3600}
BACKUP_RETENTION=${BACKUP_RETENTION:-5}

backup_loop() {
    while true; do
        sleep $BACKUP_INTERVAL
        TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
        BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"
        echo "==== Creating backup $BACKUP_FILE ===="
        tar -czf "$BACKUP_FILE" -C "$INSTANCE_DIR" .
        ls -1t "$BACKUP_DIR"/backup_*.tar.gz | tail -n +$((BACKUP_RETENTION+1)) | xargs -r rm --
        echo "==== Backup complete ===="
    done
}

backup_loop &

# -------------------------------
# 5️⃣ Start Space Engineers via Proton
# -------------------------------
echo "==== Starting Space Engineers Dedicated Server via Proton ===="

cd $SE_DIR/DedicatedServer64

# Run using Proton / Wine
exec gosu $USER_NAME xvfb-run -a wine64 SpaceEngineersDedicated.exe \
    -console \
    -path "$INSTANCE_DIR" \
    -config "$INSTANCE_DIR/SpaceEngineers-Dedicated.cfg"
