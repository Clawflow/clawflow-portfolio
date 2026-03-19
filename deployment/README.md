# 🚀 AI Kollegorna — Deployment Kit

Automatiserad installation av AI-agenter pa nya Mac minis.

## Vad skriptet gor (helt automatiskt)

1. Installerar Homebrew, Node.js, Python3
2. Installerar OpenClaw + imsg (iMessage-verktyg)
3. Installerar Python-beroenden (rembg, Pillow, anthropic, composio m.fl.)
4. Skapar workspace med alla grundfiler (MEMORY.md, SOUL.md, USER.md, IDENTITY.md)
5. Konfigurerar openclaw.json med kundens uppgifter
6. Installerar Tailscale for fjarratkomst
7. Skapar begransat kundkonto
8. Satter upp LaunchAgent — agenten startar automatiskt vid inloggning
9. Kor sjalvtest for att verifiera installationen
10. Startar OpenClaw direkt

## Hur du kor det

```bash
# Normal installation:
bash install.sh

# Visa hjalp och alla alternativ:
bash install.sh --help

# Testa utan att installera (dry-run):
bash install.sh --dry-run

# Hoppa over Tailscale och kundkonto:
bash install.sh --no-ts --no-kund
```

### Alternativ

| Flagga      | Beskrivning                                  |
|-------------|----------------------------------------------|
| `--help`    | Visa hjalptext                               |
| `--dry-run` | Simulera installation utan att gora andringar |
| `--no-kund` | Hoppa over kundkonto-skapande                |
| `--no-ts`   | Hoppa over Tailscale-installation            |

### Variabler att satta overst i skriptet

| Variabel            | Beskrivning                                 |
|---------------------|---------------------------------------------|
| `TAILSCALE_AUTHKEY` | Pre-auth key fran tailscale.com/settings/keys |
| `AGENT_NAME_DEFAULT`| Standardnamn pa AI-agenten (standard: Luna) |

Skriptet fragar interaktivt efter:
- Kundens foretagsnamn
- Kontaktpersonens namn
- Kundens telefonnummer (for iMessage)
- Anthropic API-nyckel (hamta fran console.anthropic.com)
- AI-agentens namn

## Felhantering och loggning

- Alla steg loggas till `/tmp/aikollegorna-install.log` och stdout
- Om ett steg misslyckas visas tydligt felmeddelande med stegnamn och felkod
- Installationsloggen sparas och sokvagen visas i slutet

## Sjalvtest (STEG 16)

Efter installationen kors automatiskt ett sjalvtest som kontrollerar:
- OpenClaw installerat
- Node.js installerat
- Homebrew installerat
- Python3 installerat
- imsg installerat
- Tailscale ansluten (om ej hoppat over)
- Kundkonto skapat (om ej hoppat over)
- openclaw.json finns
- LaunchAgent finns

Resultatet visas i terminalen och loggas.

## Efter installation

1. Logga in i Messages.app med ratt Apple ID
2. Be kunden skicka "Hej [Agentnamn]" fran sin telefon
3. Agenten svarar — klart!

## Loggfiler

```
/tmp/aikollegorna-install.log           <- Installationslogg
~/ai-kollegorna-logs/openclaw.log       <- Korningslogg
~/ai-kollegorna-logs/openclaw-error.log <- Felloggar
```

## Hantera LaunchAgent manuellt

```bash
# Stoppa agenten
launchctl unload ~/Library/LaunchAgents/ai.kollegorna.openclaw.plist

# Starta agenten
launchctl load ~/Library/LaunchAgents/ai.kollegorna.openclaw.plist

# Kolla status
launchctl list | grep kollegorna
```

## Filer som skapas

```
~/.openclaw/
├── openclaw.json              <- Huvudkonfiguration
└── workspace/
    ├── MEMORY.md              <- Agentens langtidsminne
    ├── SOUL.md                <- Personlighet
    ├── USER.md                <- Kundinfo
    ├── IDENTITY.md            <- Identitet
    ├── HEARTBEAT.md           <- Heartbeat-config
    ├── memory/                <- Dagloggar
    ├── skills/                <- Installerade skills
    └── agents/                <- Sub-agenter

~/Library/LaunchAgents/
└── ai.kollegorna.openclaw.plist   <- Autostart

~/ai-kollegorna-logs/
├── openclaw.log               <- Korningslogg
└── openclaw-error.log         <- Felloggar
```
