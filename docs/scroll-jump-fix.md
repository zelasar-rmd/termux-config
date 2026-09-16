# Fix: screen jumps to the bottom when you scroll up in a live TUI

**Symptom:** In Termux, while a live TUI (Claude Code, Antigravity CLI, Command
Code, etc.) is running, you scroll up to read earlier output and the screen keeps
getting "dragged" back down to the newest lines.

## Why it happens

- A terminal shows the cursor's position. When a program writes new output, the
  emulator scrolls to keep the newest line visible — it auto-pins the viewport to
  the bottom.
- TUIs that redraw on a timer (status lines, streaming) repaint continuously, so
  every repaint while you are scrolled up snaps the viewport back down.
- Exit the TUI and it stops: a shell only writes when it has output, so the TUI
  was the only thing repainting.

## The real fix: Termux's native `SCROLL` lock (0.119.0+)

Termux added a per-session auto-scroll toggle in **0.119.0** (commit `5fc2b4c`,
closes termux/termux-app#2535). Add the **`SCROLL`** key (shown as **`⇳`**) to the
extra-keys row and tap it to lock the viewport — new output keeps flowing into
scrollback without dragging you down. Tap again to resume auto-follow.

```properties
extra-keys = [ \
  ['SCROLL', 'ESC', 'HOME', 'END', 'PGUP', 'PGDN', '/', '-', '_', '='] \
]
```

**Version note:** this key only exists on Termux **0.119.0+**. The current
F-Droid stable (0.118.3) has **no scroll lock at all** — that is why the drag
feels unfixable there. Do **not** add `'SCROLL'` on 0.118.x: the key is unknown
there and gets sent to the terminal as the literal text `SCROLL`.

## Fallbacks if you are still on 0.118.x

### tmux copy-mode (a manual lock)

Run the TUI inside tmux and press **`Ctrl-b [`** to enter copy-mode: the view
freezes and new output cannot pull it down (`q` to leave). Enabled by
`tmux.conf` in this repo. Note that touch-scroll may scroll Termux's own
scrollback rather than entering copy-mode, so the `Ctrl-b [` key is the reliable
trigger.

### Pager / export (most reliable)

Get the text out of the live TUI so nothing repaints:

- Export the session and read the file: `/export` (or `/session-file` for the
  transcript path) and open it in `less -R`.
- Run a one-shot, non-interactive mode (`cmd -p "…" > out.txt`) and read `out.txt`
  with `less -R`.

## The flicker is a separate, related issue

Modern TUIs wrap every frame in DECSET 2026 *synchronized output* brackets
(`ESC[?2026h` … `ESC[?2026l`) so the terminal can paint each frame atomically.
Termux answers the probe `ESC[?2026$p` with `ESC[?2026;0$y` ("mode not
recognized"), so the brackets are dropped and each erase→redraw is painted in
pieces. Locking scroll (above) does not stop the repaint, but it does let you sit
on stable history and read without the frame changing under you.

## Notes for other tools

This applies to any Termux-hosted TUI (Claude Code, Cursor CLI, Gemini CLI,
Antigravity, etc.) — nothing here is Command-Code-specific.
