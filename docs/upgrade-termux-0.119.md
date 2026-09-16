# Runbook: migrate Termux to 0.119.0 for the native scroll lock

**Goal:** get Termux's `SCROLL` (`⇳`) auto-scroll toggle, added in **0.119.0**
(commit `5fc2b4c`, closes termux/termux-app#2535). It locks the viewport so live
TUIs can no longer drag you to the bottom. The current F-Droid stable
(**0.118.3**) predates it and has *no* scroll lock, so this requires switching
install sources.

## Why you cannot just update

F-Droid and GitHub APKs are signed with **different keys**. Android refuses an
in-place upgrade between them (and Termux apps share `sharedUserId com.termux`,
so *all* Termux apps must come from the same source). Migrating therefore means
**back up → uninstall → install → restore**.

> **This is destructive if you skip the backup.** `usr` (~2.9 GB) and `home`
> (~1.4 GB) live in the app-private dir and are wiped on uninstall. Read every
> step before running it.

## This device

| Item | Value |
| --- | --- |
| ABI | `arm64-v8a` (aarch64) |
| Android | 12 (API 31) |
| Current build | F-Droid 0.118.3 |
| Target | GitHub `v0.119.0-beta.3` |

The GitHub build is a **debuggable APK signed with a public test key** — anyone
can forge an update over it. Only install from
`https://github.com/termux/termux-app/releases`. It also stops receiving F-Droid
updates; you track GitHub from then on. (Android 12 can still kill Termux
processes to reclaim memory — unrelated to this, but expect it.)

## Pre-flight

```sh
# 1. Free up space first: the archive needs ~2–3 GB. Confirm you have it.
df -h /data/data/com.termux/files

# 2. Grant shared-storage access (creates ~/storage → /sdcard).
termux-setup-storage

# 3. Note anything you keep OUTSIDE home/usr (e.g. paths under /sdcard) — those
#    are not in the archive and are unaffected, but know where they are.
```

## 1. Back up

```sh
tar -zcf /sdcard/termux-backup.tar.gz -C /data/data/com.termux/files ./home ./usr
```

Warnings about socket files are safe to ignore. **Never** store the archive in an
app-private dir (`/data/data/com.termux`, `/sdcard/Android/data/com.termux`,
`${HOME}/storage/external-1`) — those are erased on uninstall. `/sdcard/` root is
correct.

Verify it:

```sh
ls -lh /sdcard/termux-backup.tar.gz
tar -tzf /sdcard/termux-backup.tar.gz >/dev/null && echo "ARCHIVE OK"
```

## 2. Download the APK

Open this on the device and save it to `/sdcard` (e.g. Downloads):

```
https://github.com/termux/termux-app/releases/download/v0.119.0-beta.3/termux-app_v0.119.0-beta.3+apt-android-7-github-debug_arm64-v8a.apk
```

(`apt-android-7` variant for Android ≥ 7; `arm64-v8a` matches this device.)

## 3. Uninstall

`Android Settings → Apps` and uninstall **Termux and every plugin you have**
(Termux:API, :Boot, :Float, :Styling, :Tasker, :Widget). Uninstalling the core
app wipes `/data/data/com.termux`.

## 4. Install + restore

1. Install the APK from step 2 and open Termux; let bootstrap finish.
2. In the fresh Termux:

```sh
termux-setup-storage
tar -zxf /sdcard/termux-backup.tar.gz -C /data/data/com.termux/files --recursive-unlink --preserve-permissions
```

3. Close Termux from the notification's **exit** button and reopen it.

## 5. Verify

```sh
echo "$TERMUX_VERSION"          # expect 0.119.0-beta.3
bash ~/termux-config/install.sh # re-apply this repo's config
```

Then add the scroll lock to `~/.termux/termux.properties` — **now safe**, because
the key exists:

```properties
extra-keys = [ \
  ['SCROLL', 'ESC', 'HOME', 'END', 'PGUP', 'PGDN', '/', '-', '_', '='], \
  ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12'] \
]
```

```sh
termux-reload-settings
```

Tap **`⇳`** while a TUI streams: the viewport locks and new output no longer
drags you down. Tap again to resume auto-follow. (Do **not** add `'SCROLL'` on
0.118.x — the key is unknown there and is typed as literal text.)

Keep `/sdcard/termux-backup.tar.gz` until everything works.

## If you would rather not migrate

Stay on F-Droid 0.118.3 and read outside the live TUI: `/export` then `less -R`,
or `cmd -p "…" > out.txt`. tmux copy-mode (`Ctrl-b [`) also works but needs
pressing the key — touch-scroll goes to Termux's own scrollback, not copy-mode.
See [scroll-jump-fix.md](scroll-jump-fix.md).
