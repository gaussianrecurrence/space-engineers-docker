#!/bin/bash
set -e

APP_ID=298740
WORKSHOP_APP_ID=244850
INSTALL_DIR="/home/steam/spaceengineers"
INSTANCE_DIR="/home/steam/instance"
BACKUP_DIR="/home/steam/backups"
STEAMCMD="/home/steam/steamcmd/steamcmd.sh"

BACKUP_INTERVAL=${BACKUP_INTERVAL:-3600}
BACKUP_RETENTION=${BACKUP_RETENTION:-5}

mkdir -p "$INSTALL_DIR" "$INSTANCE_DIR" "$BACKUP_DIR"

echo "==== Updating Space Engineers Dedicated Server ===="

if [ -n "$STEAM_USER" ] && [ -n "$STEAM_PASS" ]; then
    LOGIN_CMD="+login $STEAM_USER $STEAM_PASS"
else
    LOGIN_CMD="+login anonymous"
fi

$STEAMCMD \
    $LOGIN_CMD \
    +force_install_dir $INSTALL_DIR \
    +app_update $APP_ID validate \
    +quit

echo "==== Downloading Workshop Mods ===="

if [ -n "$WORKSHOP_MOD_IDS" ]; then
    IFS=',' read -ra MODS <<< "$WORKSHOP_MOD_IDS"
    for MOD_ID in "${MODS[@]}"; do
        echo "Downloading mod $MOD_ID"
        $STEAMCMD \
            $LOGIN_CMD \
            +workshop_download_item $WORKSHOP_APP_ID $MOD_ID validate \
            +quit
    done
fi

backup_loop() {
    while true; do
        sleep "$BACKUP_INTERVAL"

        TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
        BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"

        echo "==== Creating backup: $BACKUP_FILE ===="
        tar -czf "$BACKUP_FILE" -C "$INSTANCE_DIR" .

        echo "==== Applying retention policy (keep last $BACKUP_RETENTION) ===="
        ls -1t "$BACKUP_DIR"/backup_*.tar.gz | tail -n +$((BACKUP_RETENTION+1)) | xargs -r rm --

        echo "==== Backup complete ===="
    done
}

echo "==== Starting Backup Service (interval: $BACKUP_INTERVAL seconds) ===="
backup_loop &

echo "==== Starting Space Engineers Dedicated Server ===="
cd $INSTALL_DIR/DedicatedServer64

exec ./SpaceEngineersDedicated \
    -console \
    -path "$INSTANCE_DIR" \
    -config "$INSTANCE_DIR/SpaceEngineers-Dedicated.cfg"
