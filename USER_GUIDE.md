# Teams Chat Export — User Guide

## What is this?

A tool that exports all your Microsoft Teams chat history into a single HTML file you can open in any browser. Your data stays 100% local — nothing is sent anywhere.

## Requirements

- **macOS** (Apple Silicon or Intel)
- **Microsoft Edge** installed (already on most work machines)
- Internet connection (to download Python if needed, and to access Teams)

## Quick Start

### Step 1: Unblock the app (one-time only)

After unzipping, open **Terminal** (search "Terminal" in Spotlight) and paste this:

```
xattr -cr ~/Downloads/TeamsExportPortable
```

(Adjust the path if you unzipped somewhere else.)

### Step 2: Run the export

Double-click **`export-mac.command`** (or the "Teams Export" app icon).

If macOS still shows a security warning:
- Right-click the file → **Open** → click **Open** in the dialog

### Step 3: Log in to Teams

A browser window opens with Teams. If you're not already logged in:
1. Log in with your work account
2. Wait until Teams loads
3. Close the browser window

### Step 4: Wait for export

The export runs automatically. This can take **10–60 minutes** depending on how many chats you have. Don't close the Terminal window.

### Step 5: View your archive

When done, **`teams-archive.html`** opens automatically in your browser. This single file contains all your chat history.

## What to do with the file

- Copy `teams-archive.html` to a safe location (OneDrive, USB drive, external disk)
- The file works offline — no internet needed to read your chats
- You can search across all chats, filter by person/group/meeting, and browse message history

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Apple cannot verify the developer" | Right-click → Open → Open |
| "Operation not permitted" | Run `xattr -cr <path-to-folder>` in Terminal |
| Edge not found | Install Microsoft Edge from https://microsoft.com/edge |
| Export seems stuck | It's probably still working — large accounts take time |
| Empty archive | Make sure you're logged into the correct Teams account |

## Re-running

You can run the export again anytime. It skips chats already exported (`--skip-existing`), so subsequent runs are much faster.

## Privacy

- All data stays on your machine
- The tool uses your existing Edge browser session
- No data is uploaded anywhere
- The HTML file is fully self-contained (no external dependencies)
