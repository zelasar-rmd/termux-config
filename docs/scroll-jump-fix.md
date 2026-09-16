# Fix: screen jumps to the bottom when you scroll up in a live TUI

**Symptom:** In Termux, while a live TUI (Claude Code, Antigravity CLI, Command
Code, etc.) is running, you scroll up to read earlier output and the screen keeps
getting "dragged" back down to the newest lines.

## Why it happens

This is Termux behavior, not a bug in any single CLI:

- A terminal shows the cursor's position. When a program writes new output, the
  emulator scrolls to keep the newest line visible — it auto-pins the viewport to
  the bottom.
- TUIs that redraw the whole screen on a timer (progress spinners, status lines,
  live streaming) repaint continuously. Every repaint while you are scrolled up
  snaps the viewport back to the bottom.
- Why it seems app-specific: a CLI that prints lines *incrementally* (like
  Antigravity CLI running in a proot container) repaints far less often, so the
  yank happens less. Apps with an animated status line repaint every few hundred
  milliseconds and are the worst offenders.

Exit the TUI and the yank stops, because a shell only writes when it has output —
the TUI was the only thing repainting.

### The flicker is the same story

Modern TUIs also wrap every frame in DECSET 2026 *synchronized output* brackets
(`ESC[?2026h` … `ESC[?2026l`) so the terminal can paint each frame atomically.
Termux does not implement mode 2026 — it answers the probe `ESC[?2026$p` with
`ESC[?2026;0$y` ("mode not recognized") — so the brackets are dropped and each
erase→redraw is painted in pieces. That is the visible flicker while output
streams.

## The real fix: a scroll-lock via tmux copy-mode

Termux has no setting to lock the scroll position (long-standing feature request:
termux/termux-app#2535). tmux provides the lock instead:

- Run the TUI inside tmux, then press **`Ctrl-b [`** to enter copy-mode — or just
  scroll your finger/scroll-wheel, when `mouse on` is set.
- Copy-mode shows a frozen snapshot of the scrollback. New output keeps
  accumulating in history, but it **cannot drag the view down**, and the region
  you are reading stops repainting. Leave with **`q`**.

This repo ships `tmux.conf` (installed to `~/.tmux.conf`) with the settings that
make it work:

```tmux
set -g mouse on             # wheel / touch scroll enters copy-mode and holds
set -g history-limit 50000  # long transcript to read back through
set -g mode-keys vi
```

## The partial mitigation (no tmux)

If you do not want a multiplexer, make the viewport travel further per swipe and
keep more history, so a short flick gets you far enough up to read between
repaints. Add to `~/.termux/termux.properties`:

```properties
touch-scroll-multiplier = 4
terminal-transcript-rows = 50000
```

- `touch-scroll-multiplier` — how many screen rows one unit of finger movement
  scrolls (default `1.0`). Raise it (e.g. `4`) so one swipe covers several pages.
- `terminal-transcript-rows` — scrollback size, max `50000` (default `2000`), so
  there is a long history to read at all.

Apply with:

```sh
termux-reload-settings    # quick settings reload
# or force-stop Termux from Android settings for a full restart
```

## If you still need to read output at leisure

When you want a truly frozen screen, get the output out of the live TUI:

- Pipe through a pager: `<cmd> -p "..." | less -R`
- Export the session and read the file: run `/export` (or `/session-file` to find
  the transcript path) and open it in `less`.
- Run a one-shot, non-interactive mode if the CLI has one (e.g. `-p`/`--print`),
  which prints and exits with no repainting.

## Notes for other tools

This applies to any Termux-hosted TUI (Claude Code, Cursor CLI, Gemini CLI,
Antigravity, etc.) — nothing here is Command-Code-specific. The properties and
tmux settings are global.
