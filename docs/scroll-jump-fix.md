# Fix: screen jumps to the bottom when you scroll up in a live TUI

**Symptom:** In Termux, while a live, full-screen TUI (Claude Code, Antigravity
CLI, Command Code, etc.) is running, you scroll up to read earlier output and the
screen keeps getting "dragged" back down to the newest lines.

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

There is no setting in Termux or in these CLIs to "lock" the scroll position or
disable autoscroll-on-output (long-standing feature request:
termux/termux-app#2535).

## The fix that exists

Make the viewport travel further per swipe and keep more history, so a short
flick gets you far enough up to read between repaints. Add to
`~/.termux/termux.properties`:

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
Antigravity, etc.) — nothing here is Command-Code-specific. The properties are
global Termux settings.