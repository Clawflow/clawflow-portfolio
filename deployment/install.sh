#!/bin/bash
# ============================================================
#  AI KOLLEGORNA — Mac Mini Installationsscript
#  Kör detta på en ny Mac mini för att sätta upp allt automatiskt
#  Användning: bash install.sh
# ============================================================

set -e  # Avbryt vid fel

# Färger för output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log()    { echo -e "${GREEN}✅ $1${NC}"; }
info()   { echo -e "${BLUE}ℹ️  $1${NC}"; }
warn()   { echo -e "${YELLOW}⚠️  $1${NC}"; }
error()  { echo -e "${RED}❌ $1${NC}"; exit 1; }
header() { echo -e "\n${BLUE}══════════════════════════════════════${NC}"; echo -e "${BLUE}   $1${NC}"; echo -e "${BLUE}══════════════════════════════════════${NC}\n"; }

# ── VÄLKOMSTSKÄRM ────────────────────────────────────────────
clear
echo ""
echo "  ╔═══════════════════════════════════════╗"
echo "  ║      AI KOLLEGORNA AB                 ║"
echo "  ║      Mac Mini Installationsscript     ║"
echo "  ║      v1.0 — 2026                      ║"
echo "  ╚═══════════════════════════════════════╝"
echo ""
echo "  Det här skriptet installerar och konfigurerar"
echo "  en AI-agent på den här maskinen automatiskt."
echo ""

# ── KUND-INFO ────────────────────────────────────────────────
header "STEG 1: Kundinformation"

read -p "  Kundens företagsnamn: " CUSTOMER_NAME
read -p "  Kundens kontaktperson: " CUSTOMER_CONTACT
read -p "  Kundens telefon (iMessage, t.ex. +46701234567): " CUSTOMER_PHONE
read -p "  Anthropic API-nyckel (från console.anthropic.com): " ANTHROPIC_KEY
echo ""
read -p "  Vad ska AI-assistenten heta? (t.ex. Luna, Nova, Saga): " AGENT_NAME
[[ -z "$AGENT_NAME" ]] && AGENT_NAME="Luna"

echo ""
info "Konfiguration:"
echo "  Företag:    $CUSTOMER_NAME"
echo "  Kontakt:    $CUSTOMER_CONTACT"
echo "  Telefon:    $CUSTOMER_PHONE"
echo "  Agentnamn:  $AGENT_NAME"
echo ""

read -p "  Är detta korrekt? (j/n): " CONFIRM
[[ "$CONFIRM" != "j" ]] && error "Installation avbruten."

# ── SYSTEMKRAV ───────────────────────────────────────────────
header "STEG 2: Kontrollerar systemkrav"

# macOS-version
MACOS_VERSION=$(sw_vers -productVersion)
info "macOS: $MACOS_VERSION"

# Kontrollera att vi kör på Apple Silicon
ARCH=$(uname -m)
[[ "$ARCH" != "arm64" ]] && warn "Inte Apple Silicon — fortsätter ändå..."
[[ "$ARCH" == "arm64" ]] && log "Apple Silicon (arm64) bekräftat"

# Skapa loggmapp
mkdir -p ~/ai-kollegorna-logs
LOG_FILE=~/ai-kollegorna-logs/install-$(date +%Y%m%d-%H%M%S).log
info "Installationslogg: $LOG_FILE"

# ── HOMEBREW ─────────────────────────────────────────────────
header "STEG 3: Homebrew"

if command -v brew &>/dev/null; then
    log "Homebrew redan installerat"
    brew update --quiet 2>>$LOG_FILE || true
else
    info "Installerar Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>>$LOG_FILE
    
    # Lägg till i PATH (Apple Silicon)
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    log "Homebrew installerat"
fi

# ── NODE.JS ──────────────────────────────────────────────────
header "STEG 4: Node.js"

if command -v node &>/dev/null; then
    NODE_VERSION=$(node --version)
    log "Node.js redan installerat: $NODE_VERSION"
else
    info "Installerar Node.js via Homebrew..."
    brew install node 2>>$LOG_FILE
    log "Node.js installerat"
fi

# ── PYTHON ───────────────────────────────────────────────────
header "STEG 5: Python & beroenden"

if command -v python3 &>/dev/null; then
    PYTHON_VERSION=$(python3 --version)
    log "Python3 redan installerat: $PYTHON_VERSION"
else
    info "Installerar Python3..."
    brew install python3 2>>$LOG_FILE
    log "Python3 installerat"
fi

# Installera Python-paket som skills behöver
info "Installerar Python-beroenden..."
pip3 install requests httpx anthropic rembg Pillow composio-core --quiet 2>>$LOG_FILE || true
log "Python-beroenden installerade"

# ── OPENCLAW ─────────────────────────────────────────────────
header "STEG 6: OpenClaw"

if command -v openclaw &>/dev/null; then
    OPENCLAW_VERSION=$(openclaw --version 2>/dev/null || echo "okänd version")
    log "OpenClaw redan installerat: $OPENCLAW_VERSION"
else
    info "Installerar OpenClaw..."
    npm install -g openclaw 2>>$LOG_FILE
    log "OpenClaw installerat"
fi

# ── IMSG ─────────────────────────────────────────────────────
header "STEG 7: iMessage-verktyg (imsg)"

if command -v imsg &>/dev/null; then
    log "imsg redan installerat"
else
    info "Installerar imsg..."
    brew tap steipete/tap 2>>$LOG_FILE
    brew install imsg 2>>$LOG_FILE
    log "imsg installerat"
fi

# ── WORKSPACE ────────────────────────────────────────────────
header "STEG 8: Workspace & konfiguration"

WORKSPACE_DIR="$HOME/.openclaw/workspace"
mkdir -p "$WORKSPACE_DIR/memory"
mkdir -p "$WORKSPACE_DIR/skills"
mkdir -p "$WORKSPACE_DIR/agents"
mkdir -p "$HOME/.openclaw"

log "Workspace-mappar skapade: $WORKSPACE_DIR"

# ── OPENCLAW-KONFIGURATION ───────────────────────────────────
header "STEG 9: OpenClaw-konfiguration"

CONFIG_FILE="$HOME/.openclaw/openclaw.json"

cat > "$CONFIG_FILE" << JSONEOF
{
  "model": "anthropic/claude-sonnet-4-6",
  "anthropic": {
    "apiKey": "${ANTHROPIC_KEY}"
  },
  "workspace": "${WORKSPACE_DIR}",
  "channels": {
    "imessage": {
      "enabled": true,
      "allowlist": ["${CUSTOMER_PHONE}"]
    }
  },
  "heartbeat": {
    "enabled": true,
    "intervalMs": 1800000
  }
}
JSONEOF

log "OpenClaw konfigurerat"

# ── MILJÖVARIABLER ───────────────────────────────────────────
header "STEG 10: Miljövariabler"

ZSHRC="$HOME/.zshrc"

# Lägg till om de inte redan finns
grep -q "ANTHROPIC_API_KEY" "$ZSHRC" 2>/dev/null || echo "export ANTHROPIC_API_KEY=\"${ANTHROPIC_KEY}\"" >> "$ZSHRC"
grep -q "OPENCLAW_WORKSPACE" "$ZSHRC" 2>/dev/null || echo "export OPENCLAW_WORKSPACE=\"${WORKSPACE_DIR}\"" >> "$ZSHRC"

log "Miljövariabler sparade i ~/.zshrc"

# ── WORKSPACE-FILER ──────────────────────────────────────────
header "STEG 11: Grundfiler"

# IDENTITY.md
cat > "$WORKSPACE_DIR/IDENTITY.md" << EOF
- **Name:** ${AGENT_NAME}
- **Creature:** AI-driven business assistant for ${CUSTOMER_NAME}
- **Vibe:** Professional yet warm
- **Emoji:** 🌙
EOF

# USER.md
cat > "$WORKSPACE_DIR/USER.md" << EOF
- **Company:** ${CUSTOMER_NAME}
- **Contact:** ${CUSTOMER_CONTACT}
- **Phone:** ${CUSTOMER_PHONE}
- **Notes:** AI-agent installerad av AI Kollegorna AB
EOF

# MEMORY.md (tomt)
cat > "$WORKSPACE_DIR/MEMORY.md" << EOF
# 🧠 MEMORY.md — ${AGENT_NAME}s långtidsminne

> Installerad av AI Kollegorna AB för ${CUSTOMER_NAME}
> Kontakt: ${CUSTOMER_CONTACT}

---

## 📋 REGLER & PREFERENSER

- Kommunicera alltid på svenska
- Skicka iMessage-notiser direkt när uppgifter är klara
- Besvara endast meddelanden från ${CUSTOMER_PHONE}

---
EOF

# HEARTBEAT.md
cat > "$WORKSPACE_DIR/HEARTBEAT.md" << EOF
# Heartbeat

Om Claude Code-sessioner är aktiva och väntar på input — hantera dem.
Om inget behöver uppmärksamhet → HEARTBEAT_OK
EOF

# SOUL.md
cat > "$WORKSPACE_DIR/SOUL.md" << EOF
# SOUL.md

Du är ${AGENT_NAME}, AI-assistent installerad av AI Kollegorna AB hos ${CUSTOMER_NAME}.

Var genuint hjälpsam. Ha åsikter. Var resursstark innan du frågar.
Respektera att du är en gäst i deras verksamhet.
EOF

log "Grundfiler skapade"

# ── LAUNCHAGENT (AUTOSTART) ──────────────────────────────────
header "STEG 12: Autostart (LaunchAgent)"

PLIST_DIR="$HOME/Library/LaunchAgents"
PLIST_FILE="$PLIST_DIR/ai.kollegorna.openclaw.plist"
mkdir -p "$PLIST_DIR"

OPENCLAW_PATH=$(which openclaw)

cat > "$PLIST_FILE" << PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>ai.kollegorna.openclaw</string>

  <key>ProgramArguments</key>
  <array>
    <string>${OPENCLAW_PATH}</string>
    <string>gateway</string>
    <string>start</string>
  </array>

  <key>RunAtLoad</key>
  <true/>

  <key>KeepAlive</key>
  <true/>

  <key>StandardOutPath</key>
  <string>${HOME}/ai-kollegorna-logs/openclaw.log</string>

  <key>StandardErrorPath</key>
  <string>${HOME}/ai-kollegorna-logs/openclaw-error.log</string>

  <key>EnvironmentVariables</key>
  <dict>
    <key>ANTHROPIC_API_KEY</key>
    <string>${ANTHROPIC_KEY}</string>
    <key>PATH</key>
    <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
  </dict>

  <key>WorkingDirectory</key>
  <string>${WORKSPACE_DIR}</string>
</dict>
</plist>
PLISTEOF

# Ladda LaunchAgent
launchctl unload "$PLIST_FILE" 2>/dev/null || true
launchctl load "$PLIST_FILE" 2>>$LOG_FILE
log "LaunchAgent installerad och aktiverad — OpenClaw startar automatiskt vid inloggning"

# ── STARTA OPENCLAW ──────────────────────────────────────────
header "STEG 13: Startar OpenClaw"

info "Startar OpenClaw gateway..."
sleep 2

if launchctl list | grep -q "ai.kollegorna.openclaw"; then
    log "OpenClaw körs via LaunchAgent"
else
    warn "LaunchAgent kanske inte startade direkt — försöker manuellt..."
    openclaw gateway start &
    sleep 3
    log "OpenClaw startad manuellt"
fi

# ── KLAR ─────────────────────────────────────────────────────
header "✅ INSTALLATION KLAR!"

echo ""
echo "  ╔═══════════════════════════════════════════════╗"
echo "  ║  ${AGENT_NAME} är nu installerad och redo!$(printf '%*s' $((19-${#AGENT_NAME})) '')║"
echo "  ║                                               ║"
echo "  ║  Kund:    ${CUSTOMER_NAME}$(printf '%*s' $((23-${#CUSTOMER_NAME})) '')║"
echo "  ║  Kontakt: ${CUSTOMER_CONTACT}$(printf '%*s' $((23-${#CUSTOMER_CONTACT})) '')║"
echo "  ║  iMessage: ${CUSTOMER_PHONE}$(printf '%*s' $((22-${#CUSTOMER_PHONE})) '')║"
echo "  ║                                               ║"
echo "  ║  ${AGENT_NAME} startar automatiskt vid inloggning. $(printf '%*s' $((5-${#AGENT_NAME})) '')║"
echo "  ║  Loggfiler: ~/ai-kollegorna-logs/             ║"
echo "  ╚═══════════════════════════════════════════════╝"
echo ""
echo "  Nästa steg:"
echo "  1. Logga in i Messages.app med kundkontaktens Apple ID"
echo "  2. Skicka 'Hej ${AGENT_NAME}' från kundens telefon (${CUSTOMER_PHONE})"
echo "  3. ${AGENT_NAME} svarar automatiskt — installationen är klar!"
echo ""
echo "  Installationslogg sparad: $LOG_FILE"
echo ""
