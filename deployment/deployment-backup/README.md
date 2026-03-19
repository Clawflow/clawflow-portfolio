# 🚀 AI Kollegorna — Deployment Kit

Automatiserad installation av Luna på en ny Mac mini.

## Vad skriptet gör (helt automatiskt)

1. Installerar Homebrew, Node.js, Python3
2. Installerar OpenClaw + imsg (iMessage-verktyg)
3. Installerar Python-beroenden (rembg, Pillow, anthropic, composio m.fl.)
4. Skapar workspace med alla grundfiler (MEMORY.md, SOUL.md, USER.md, IDENTITY.md)
5. Konfigurerar openclaw.json med kundens uppgifter
6. Sätter upp LaunchAgent — Luna startar automatiskt vid inloggning
7. Startar OpenClaw direkt

## Hur du kör det

```bash
# Ladda ner och kör på ny Mac mini:
curl -fsSL https://raw.githubusercontent.com/Clawflow/clawflow-portfolio/main/deployment/install.sh | bash

# Eller om du har filen lokalt:
bash install.sh
```

Skriptet frågar efter:
- Kundens företagsnamn
- Kontaktpersonens namn
- Kundens telefonnummer (för iMessage)
- Anthropic API-nyckel (hämta från console.anthropic.com)

## Efter installation

1. Logga in i Messages.app med rätt Apple ID
2. Be kunden skicka "Hej Luna" från sin telefon
3. Luna svarar — klart!

## Loggfiler

```
~/ai-kollegorna-logs/openclaw.log        ← Körningslogg
~/ai-kollegorna-logs/openclaw-error.log  ← Felloggar
~/ai-kollegorna-logs/install-*.log       ← Installationslogg
```

## Hantera LaunchAgent manuellt

```bash
# Stoppa Luna
launchctl unload ~/Library/LaunchAgents/ai.kollegorna.openclaw.plist

# Starta Luna
launchctl load ~/Library/LaunchAgents/ai.kollegorna.openclaw.plist

# Kolla status
launchctl list | grep kollegorna
```

## Filer som skapas

```
~/.openclaw/
├── openclaw.json              ← Huvudkonfiguration
└── workspace/
    ├── MEMORY.md              ← Lunas långtidsminne
    ├── SOUL.md                ← Personlighet
    ├── USER.md                ← Kundinfo
    ├── IDENTITY.md            ← Identitet
    ├── HEARTBEAT.md           ← Heartbeat-config
    ├── memory/                ← Dagloggar
    ├── skills/                ← Installerade skills
    └── agents/                ← Sub-agenter

~/Library/LaunchAgents/
└── ai.kollegorna.openclaw.plist   ← Autostart

~/ai-kollegorna-logs/
├── openclaw.log               ← Körningslogg
└── openclaw-error.log         ← Felloggar
```
