# Customized Termux Configuration

Personal Termux setup featuring a 3-layer touch key bar, resource clearance utilities, and bracketed paste settings.

## Features
- **3-Layer Touch Key Bar:** Includes `DRAWER`, `KILL`, `CLR` (Clear Line), `FREE` (Resource Cleaner), `KEYBOARD`, and `F1-F12`.
- **Resource Cleaner (`sys-clean`):** Safely flushes system buffers and cleans package cache without disturbing background servers.
- **Bracketed Paste (`.inputrc`):** Prevents multiline paste errors.
- **TUI reading (`tmux.conf` + scroll fix):** Termux 0.119.0+ users add the native `SCROLL` (`⇳`) key to lock the viewport; older builds use the tmux copy-mode fallback.

## Troubleshooting
- [Screen jumps to the bottom / flickers while reading in a live TUI](docs/scroll-jump-fix.md) — why it happens and how to stop it.
- [Runbook: migrate Termux to 0.119.0 for the native scroll lock](docs/upgrade-termux-0.119.md) — backup, source switch, and restore.

## Quick 1-Line Installation on New Device
```bash
bash <(curl -sSL https://raw.githubusercontent.com/zelasar-rmd/termux-config/main/install.sh)
```
