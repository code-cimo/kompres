#!/usr/bin/env bash
# ==============================================================================
# Immich Media Optimizer - Universal Cross-Platform Interactive Installer
# Mendukung: Debian/Ubuntu/DietPi, Arch/Manjaro, Fedora/RHEL/CentOS, Alpine, macOS (Homebrew)
# ==============================================================================

set -e

# Warna untuk output terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$APP_DIR"

echo -e "${CYAN}======================================================================${NC}"
echo -e "${PURPLE}🚀  IMMICH MEDIA OPTIMIZER & WEB MONITOR - SETUP WIZARD & INSTALLER ${NC}"
echo -e "${CYAN}======================================================================${NC}"
echo -e "📂 Direktori Kerja : ${YELLOW}$APP_DIR${NC}"

# 1. Deteksi OS & Package Manager
OS_TYPE="$(uname -s)"
PKG_MANAGER=""
SUDO_CMD=""

if [ "$EUID" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO_CMD="sudo"
    fi
fi

detect_pkg_manager() {
    case "$OS_TYPE" in
        Linux*)
            if [ -f /etc/debian_version ] || command -v apt-get >/dev/null 2>&1; then
                PKG_MANAGER="apt"
            elif [ -f /etc/arch-release ] || command -v pacman >/dev/null 2>&1; then
                PKG_MANAGER="pacman"
            elif [ -f /etc/fedora-release ] || [ -f /etc/redhat-release ] || command -v dnf >/dev/null 2>&1; then
                PKG_MANAGER="dnf"
            elif [ -f /etc/alpine-release ] || command -v apk >/dev/null 2>&1; then
                PKG_MANAGER="apk"
            else
                PKG_MANAGER="unknown_linux"
            fi
            ;;
        Darwin*)
            if command -v brew >/dev/null 2>&1; then
                PKG_MANAGER="brew"
            else
                PKG_MANAGER="darwin_no_brew"
            fi
            ;;
        *)
            PKG_MANAGER="unsupported"
            ;;
    esac
}

detect_pkg_manager
echo -e "🖥️  Sistem Operasi  : ${GREEN}$OS_TYPE${NC} (Package Manager: ${YELLOW}$PKG_MANAGER${NC})"

# 2. Fungsi Pemasangan Dependensi
install_dependencies() {
    echo -e "\n${BLUE}📦 [1/5] Memeriksa & Menginstall Dependensi Sistem...${NC}"

    case "$PKG_MANAGER" in
        apt)
            echo -e "Memeriksa paket untuk sistem Debian / Ubuntu / DietPi..."
            PKGS=""
            command -v ffmpeg >/dev/null 2>&1 || PKGS="$PKGS ffmpeg"
            command -v exiftool >/dev/null 2>&1 || PKGS="$PKGS libimage-exiftool-perl"
            (command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1) || PKGS="$PKGS imagemagick"
            (dpkg -s libheif-examples >/dev/null 2>&1 || command -v heif-enc >/dev/null 2>&1) || PKGS="$PKGS libheif-examples"
            command -v rclone >/dev/null 2>&1 || PKGS="$PKGS rclone"
            command -v go >/dev/null 2>&1 || PKGS="$PKGS golang-go"

            if [ -n "$PKGS" ]; then
                echo -e "${YELLOW}Menginstall paket:${NC}$PKGS"
                $SUDO_CMD apt-get update -qq
                $SUDO_CMD apt-get install -y -qq $PKGS
            else
                echo -e "${GREEN}✓ Semua dependensi APT sudah terpasang.${NC}"
            fi
            ;;
        pacman)
            echo -e "Memeriksa paket untuk sistem Arch / Manjaro..."
            PKGS=""
            command -v ffmpeg >/dev/null 2>&1 || PKGS="$PKGS ffmpeg"
            command -v exiftool >/dev/null 2>&1 || PKGS="$PKGS perl-image-exiftool"
            (command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1) || PKGS="$PKGS imagemagick"
            command -v heif-enc >/dev/null 2>&1 || PKGS="$PKGS libheif"
            command -v rclone >/dev/null 2>&1 || PKGS="$PKGS rclone"
            command -v go >/dev/null 2>&1 || PKGS="$PKGS go"

            if [ -n "$PKGS" ]; then
                echo -e "${YELLOW}Menginstall paket:${NC}$PKGS"
                $SUDO_CMD pacman -Sy --noconfirm --needed $PKGS
            else
                echo -e "${GREEN}✓ Semua dependensi Pacman sudah terpasang.${NC}"
            fi
            ;;
        dnf)
            echo -e "Memeriksa paket untuk sistem Fedora / RHEL / CentOS..."
            PKGS=""
            command -v ffmpeg >/dev/null 2>&1 || PKGS="$PKGS ffmpeg"
            command -v exiftool >/dev/null 2>&1 || PKGS="$PKGS perl-Image-ExifTool"
            (command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1) || PKGS="$PKGS ImageMagick"
            command -v heif-enc >/dev/null 2>&1 || PKGS="$PKGS libheif-tools"
            command -v rclone >/dev/null 2>&1 || PKGS="$PKGS rclone"
            command -v go >/dev/null 2>&1 || PKGS="$PKGS golang"

            if [ -n "$PKGS" ]; then
                echo -e "${YELLOW}Menginstall paket:${NC}$PKGS"
                $SUDO_CMD dnf install -y $PKGS
            else
                echo -e "${GREEN}✓ Semua dependensi DNF sudah terpasang.${NC}"
            fi
            ;;
        apk)
            echo -e "Memeriksa paket untuk sistem Alpine Linux..."
            PKGS=""
            command -v ffmpeg >/dev/null 2>&1 || PKGS="$PKGS ffmpeg"
            command -v exiftool >/dev/null 2>&1 || PKGS="$PKGS exiftool"
            (command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1) || PKGS="$PKGS imagemagick"
            command -v heif-enc >/dev/null 2>&1 || PKGS="$PKGS libheif"
            command -v rclone >/dev/null 2>&1 || PKGS="$PKGS rclone"
            command -v go >/dev/null 2>&1 || PKGS="$PKGS go"

            if [ -n "$PKGS" ]; then
                echo -e "${YELLOW}Menginstall paket:${NC}$PKGS"
                $SUDO_CMD apk add --no-cache $PKGS
            else
                echo -e "${GREEN}✓ Semua dependensi APK sudah terpasang.${NC}"
            fi
            ;;
        brew)
            echo -e "Memeriksa paket untuk macOS (Homebrew)..."
            command -v ffmpeg >/dev/null 2>&1 || brew install ffmpeg
            command -v exiftool >/dev/null 2>&1 || brew install exiftool
            command -v magick >/dev/null 2>&1 || brew install imagemagick
            command -v heif-enc >/dev/null 2>&1 || brew install libheif
            command -v rclone >/dev/null 2>&1 || brew install rclone
            command -v go >/dev/null 2>&1 || brew install go
            echo -e "${GREEN}✓ Semua dependensi Homebrew siap.${NC}"
            ;;
        *)
            echo -e "${YELLOW}⚠️  Package manager tidak dikenali secara otomatis.${NC}"
            echo -e "Harap pastikan tools berikut terpasang manual: ffmpeg, exiftool, imagemagick, libheif, rclone, golang"
            ;;
    esac
}

install_dependencies

# 3. Interaktif: Konfigurasi Direktori & Pengaturan Sistem
echo -e "\n${BLUE}⚙️  [2/5] Konfigurasi Awal Aplikasi...${NC}"

# Nilai Default
DEFAULT_UPLOAD_DIR="/mnt/hdd1/immich/upload/upload"
[ ! -d "$DEFAULT_UPLOAD_DIR" ] && DEFAULT_UPLOAD_DIR="$PWD/media_test"

DEFAULT_PORT="5555"
DEFAULT_MODE="force"
DEFAULT_PHOTO_QUALITY="82"
DEFAULT_VIDEO_CRF="26"

# Cek jika config.json sudah ada sebelumnya
if [ -f "config.json" ]; then
    echo -e "${YELLOW}Ditemukan config.json yang sudah ada.${NC}"
    read -p "Apakah Anda ingin membuat ulang konfigurasi secara interaktif? (y/N): " RECONFIG
    RECONFIG=${RECONFIG:-N}
else
    RECONFIG="y"
fi

if [[ "$RECONFIG" =~ ^[Yy]$ ]]; then
    echo -e "\nSilakan masukkan preferensi folder dan parameter (tekan [ENTER] untuk default):"
    
    # Input folder yang akan diolah
    while true; do
        read -p "📁 Folder Media Immich Upload [$DEFAULT_UPLOAD_DIR]: " INPUT_UPLOAD_DIR
        TARGET_UPLOAD_DIR="${INPUT_UPLOAD_DIR:-$DEFAULT_UPLOAD_DIR}"
        
        if [ ! -d "$TARGET_UPLOAD_DIR" ]; then
            echo -e "${YELLOW}Direktori '$TARGET_UPLOAD_DIR' belum ada.${NC}"
            read -p "Buat direktori tersebut sekarang? (Y/n): " MKDIR_CONFIRM
            MKDIR_CONFIRM=${MKDIR_CONFIRM:-Y}
            if [[ "$MKDIR_CONFIRM" =~ ^[Yy]$ ]]; then
                mkdir -p "$TARGET_UPLOAD_DIR" 2>/dev/null || $SUDO_CMD mkdir -p "$TARGET_UPLOAD_DIR"
                echo -e "${GREEN}✓ Direktori berhasil dibuat.${NC}"
                break
            fi
        else
            break
        fi
    done

    # Input Port Web UI
    read -p "🌐 Port Web UI [$DEFAULT_PORT]: " INPUT_PORT
    TARGET_PORT="${INPUT_PORT:-$DEFAULT_PORT}"

    # Mode Kompresi
    echo -e "Pilih Mode Kompresi:"
    echo -e "  1) force  (Kompres semua file yang belum dioptimalkan)"
    echo -e "  2) normal (Kompres berdasarkan kuota/jadwal normal)"
    read -p "Pilihan (1/2) [1]: " INPUT_MODE_NUM
    if [ "$INPUT_MODE_NUM" = "2" ]; then
        TARGET_MODE="normal"
    else
        TARGET_MODE="force"
    fi

    # Video CRF
    read -p "🎬 Video CRF (18-32, semakin tinggi semakin hemat, rek: 26) [$DEFAULT_VIDEO_CRF]: " INPUT_CRF
    TARGET_CRF="${INPUT_CRF:-$DEFAULT_VIDEO_CRF}"

    # Photo Quality
    read -p "📷 Photo Quality (70-95, rek: 82) [$DEFAULT_PHOTO_QUALITY]: " INPUT_QUALITY
    TARGET_QUALITY="${INPUT_QUALITY:-$DEFAULT_PHOTO_QUALITY}"

    # Password Web UI
    read -p "🔑 Password Web UI (default: admin): " INPUT_PASS
    if [ -n "$INPUT_PASS" ]; then
        # Hitung sha256
        if command -v sha256sum >/dev/null 2>&1; then
            PASS_HASH=$(echo -n "$INPUT_PASS" | sha256sum | awk '{print $1}')
        elif command -v shasum >/dev/null 2>&1; then
            PASS_HASH=$(echo -n "$INPUT_PASS" | shasum -a 256 | awk '{print $1}')
        else
            PASS_HASH="8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918"
        fi
        PASS_HINT="Custom Password"
    else
        PASS_HASH="8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918"
        PASS_HINT="admin (default)"
    fi

    # Deteksi path sensor suhu thermal zone
    THERMAL_PATH="/sys/class/thermal/thermal_zone0/temp"
    if [ ! -f "$THERMAL_PATH" ]; then
        # Coba cari thermal zone lain jika ada
        FOUND_ZONE=$(ls /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n 1 || true)
        if [ -n "$FOUND_ZONE" ]; then
            THERMAL_PATH="$FOUND_ZONE"
        else
            THERMAL_PATH=""
        fi
    fi

    # Buat file config.json
    cat <<EOF > config.json
{
  "server": {
    "host": "0.0.0.0",
    "port": $TARGET_PORT,
    "auth_enabled": true,
    "password_hash": "$PASS_HASH",
    "password_hint": "$PASS_HINT"
  },
  "storage": {
    "immich_upload_dir": "$TARGET_UPLOAD_DIR",
    "state_file_path": "optimizer_state.json",
    "log_dir": "logs"
  },
  "compression": {
    "mode": "$TARGET_MODE",
    "video_codec": "libx265",
    "video_preset": "ultrafast",
    "video_crf": $TARGET_CRF,
    "video_max_height": 1080,
    "video_threads": 1,
    "photo_quality": $TARGET_QUALITY,
    "photo_max_dim": 2560,
    "max_video_workers": 1,
    "max_photo_workers": 2
  },
  "thermal": {
    "enabled": $([ -n "$THERMAL_PATH" ] && echo "true" || echo "false"),
    "max_temp_c": 75,
    "cooldown_temp_c": 65,
    "thermal_zone_path": "$THERMAL_PATH"
  },
  "schedule": {
    "enabled": true,
    "start_hour": 1,
    "end_hour": 6
  },
  "backup": {
    "enabled": false,
    "mode": "normal",
    "rclone_remote": "mega:ImmichBackup",
    "rclone_args": "--transfers=1 --checkers=2 --fast-list --bwlimit=5M"
  }
}
EOF
    echo -e "${GREEN}✓ config.json berhasil dibuat dan disesuaikan.${NC}"
else
    echo -e "${GREEN}✓ Menggunakan config.json yang sudah ada.${NC}"
fi

# 4. Kompilasi Binary Optimizer
echo -e "\n${BLUE}🔨 [3/5] Mengompilasi Binary Golang...${NC}"
mkdir -p logs static

if command -v go >/dev/null 2>&1; then
    go build -ldflags="-s -w" -o optimizer main.go
    chmod +x optimizer
    echo -e "${GREEN}✓ Binary 'optimizer' berhasil dikompilasi.${NC}"
else
    echo -e "${RED}❌ Go compiler tidak ditemukan! Harap pasang 'go' terlebih dahulu.${NC}"
    exit 1
fi

# 5. Opsi Pasang Auto-Start (systemd untuk Linux, atau Run langsung)
echo -e "\n${BLUE}🚀 [4/5] Opsi Auto-Run & Startup...${NC}"

if [ "$OS_TYPE" = "Linux" ] && command -v systemctl >/dev/null 2>&1; then
    read -p "Apakah Anda ingin memasang service auto-run tiap boot (systemd)? (Y/n): " INSTALL_SYSTEMD
    INSTALL_SYSTEMD=${INSTALL_SYSTEMD:-Y}

    if [[ "$INSTALL_SYSTEMD" =~ ^[Yy]$ ]]; then
        SERVICE_NAME="immich-optimizer"
        SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

        cat <<EOF | $SUDO_CMD tee "$SERVICE_FILE" >/dev/null
[Unit]
Description=Immich Media Optimizer & Web Monitor Service
Documentation=https://github.com/immich-app/immich
After=network.target local-fs.target
Wants=network-online.target

[Service]
Type=simple
User=$(whoami)
WorkingDirectory=$APP_DIR
ExecStart=$APP_DIR/optimizer
Restart=always
RestartSec=5s
KillMode=process
LimitNOFILE=65536
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
StandardOutput=journal
StandardError=journal
SyslogIdentifier=immich-optimizer

MemoryMax=1600M
CPUWeight=80

[Install]
WantedBy=multi-user.target
EOF
        $SUDO_CMD systemctl daemon-reload
        $SUDO_CMD systemctl enable "${SERVICE_NAME}.service"
        $SUDO_CMD systemctl restart "${SERVICE_NAME}.service"
        echo -e "${GREEN}✓ Systemd service ${SERVICE_NAME} berhasil dipasang & diaktifkan!${NC}"
    fi
fi

# 6. Selesai
IP_ADDR=$(hostname -I 2>/dev/null | awk '{print $1}')
[ -z "$IP_ADDR" ] && IP_ADDR="localhost"

CURRENT_PORT=$(grep -o '"port": *[0-9]*' config.json | head -n 1 | awk '{print $2}')
[ -z "$CURRENT_PORT" ] && CURRENT_PORT="5555"

echo -e "\n${CYAN}======================================================================${NC}"
echo -e "${GREEN}🎉 INSTALASI SELESAI & PROGRAM SIAP DIGUNAKAN!${NC}"
echo -e "${CYAN}======================================================================${NC}"
echo -e "🌐 Web Dashboard : ${YELLOW}http://${IP_ADDR}:${CURRENT_PORT}${NC}"
echo -e "🔑 Password      : admin (atau sesuai yang Anda input)"
echo -e "\n💡 Perintah Menjalankan Manual:"
echo -e "   ${PURPLE}./optimizer${NC}          (atau ./onerun.sh)"
if command -v systemctl >/dev/null 2>&1; then
    echo -e "\n💡 Perintah Manajemen Service (systemd):"
    echo -e "   sudo systemctl status immich-optimizer"
    echo -e "   sudo systemctl restart immich-optimizer"
    echo -e "   sudo systemctl stop immich-optimizer"
    echo -e "   sudo journalctl -u immich-optimizer -f"
fi
echo -e "${CYAN}======================================================================${NC}\n"
