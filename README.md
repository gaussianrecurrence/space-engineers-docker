# 🚀 Space Engineers Dedicated Server (Docker Image)

This repository provides a **Docker image** for running a  
**Space Engineers Dedicated Server** using **SteamCMD**, with full **Steam Workshop mod support**.

It is focused purely on the Docker image itself — no Docker Compose or deployment tooling included.

---

## 🎮 About

This image runs the dedicated server for **Space Engineers**, developed by Keen Software House.

Steam App IDs used:

| Component | App ID |
|------------|--------|
| Dedicated Server | `298740` |
| Workshop Content | `244850` |

---

# ✨ Features

- ✅ Automatic server installation via SteamCMD  
- ✅ Automatic server updates on container start  
- ✅ Steam Workshop mod download support  
- ✅ Optional private mod support (Steam login)  
- ✅ Persistent world/config support via volume mount  
- ✅ Runs as non-root user  

---

# 📦 Requirements

- Docker 24+
- Linux host recommended
- Minimum 8GB RAM for modded servers

> ⚠️ Space Engineers is Windows-native. Linux support may vary depending on host environment.

---

# 🏗 Build the Image

Clone the repository:

```bash
git clone https://github.com/gaussianrecurrence/space-engineers-docker.git
cd spaceengineers-ds
```

Build the Docker image:

```bash
docker build -t spaceengineers-ds .
```

---

# ▶️ Run the Container

Example minimal run:

```bash
docker run -d \
  --name spaceengineers-ds \
  -p 27016:27016/udp \
  -p 27016:27016/tcp \
  -v $(pwd)/instance:/home/steam/instance \
  -v $(pwd)/spaceengineers:/home/steam/spaceengineers \
  spaceengineers-ds
```

---

# 📁 Volumes

You **must mount volumes** to persist data.

| Host Path | Container Path | Purpose |
|------------|----------------|----------|
| `./instance` | `/home/steam/instance` | World saves & config |
| `./spaceengineers` | `/home/steam/spaceengineers` | Server installation |

If volumes are not mounted, all data will be lost when the container is removed.

---

# 🌐 Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 27016 | UDP | Game traffic |
| 27016 | TCP | Steam query |

Make sure these ports are open in your firewall if hosting publicly.

---

# 🧩 Mod Support

Workshop mods are downloaded automatically at container startup.

To enable mods, set the environment variable:

```bash
-e WORKSHOP_MOD_IDS=1234567890,9876543210
```

Comma-separated list of Steam Workshop mod IDs.

Internally, mods are downloaded using:

```
workshop_download_item 244850 <mod_id>
```

They are stored in:

```
steamapps/workshop/content/244850/<mod_id>
```

---

## 🔧 Loading Mods in Server Config

Mods must also be added to your `SpaceEngineers-Dedicated.cfg`:

```xml
<Mods>
  <ModItem FriendlyName="Example Mod" PublishedFileId="1234567890" />
</Mods>
```

The server reads this config and loads the mods automatically.

---

# 🔐 Private Workshop Mods

To download private mods, provide Steam credentials:

```bash
-e STEAM_USER=yourusername \
-e STEAM_PASS=yourpassword
```

⚠️ It is recommended to use Docker secrets or environment files instead of plaintext passwords.

---

# 📄 Configuration

The server reads configuration from:

```
/home/steam/instance/SpaceEngineers-Dedicated.cfg
```

You must provide this file inside your mounted `instance` directory.

If it does not exist, the server will fail to start.

---

# 💻 Recommended Hardware

| Players | RAM |
|----------|------|
| 1–5 | 8GB |
| 5–10 | 16GB |
| 10+ modded | 32GB+ |

CPU single-core performance is more important than core count.

---

# 🔒 Security Notes

- Do not expose unnecessary ports
- Use strong admin passwords in config
- Avoid running with privileged mode
- Use secure handling for Steam credentials

---

# 📜 License

MIT License

---

Happy engineering 🚀
