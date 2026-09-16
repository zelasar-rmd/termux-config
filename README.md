# Customized Termux Configuration

Personal Termux setup featuring a 3-layer touch key bar, resource clearance utilities, and bracketed paste settings.

## Features
- **3-Layer Touch Key Bar:** Includes `DRAWER`, `KILL`, `CLR` (Clear Line), `FREE` (Resource Cleaner), `KEYBOARD`, and `F1-F12`.
- **Resource Cleaner (`sys-clean`):** Safely flushes system buffers and cleans package cache without disturbing background servers.
- **Bracketed Paste (`.inputrc`):** Prevents multiline paste errors.
- **TUI scroll-lock (`tmux.conf`):** tmux copy-mode holds the view so live TUIs can't drag you to the bottom; enables swipe-to-scroll and a 50k history.
- **TUI scroll fix (`termux.properties`):** Screen stays put while reading up in live TUIs (Claude Code, Command Code, Antigravity, etc.).

## Troubleshooting
- [Screen jumps to the bottom / flickers while reading in a live TUI](docs/scroll-jump-fix.md) — why it happens and how to stop it.

## Quick 1-Line Installation on New Device
```bash
bash <(curl -sSL https://raw.githubusercontent.com/zelasar-rmd/termux-config/main/install.sh)
```
