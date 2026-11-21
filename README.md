# Zen Bookmarks Search (Alfred Workflow)

Search your Zen browser bookmarks via Alfred.

## Description

This Alfred workflow lets you instantly search bookmarks from the Zen browser profile. Zen locks its bookmarks database while running, so the workflow searches a private snapshot that refreshes whenever Zen saves a change.
## Features
- Index bookmarks from the default profile of Zen (a Firefox fork)
- Search by bookmark title, URL, tags, and description (set by webpage)
- Open bookmarks in primary or secondary browser (configurable)
- Large-Type view of tags and full URL (via ⌘L)
- Hide bookmarks from Alfred search by applying the tag Exclude-Alfred (case sensitive)
## Requirements
- macOS with Alfred installed (version compatible with your workflow).
- jq (command-line JSON processor) installed — macOS 15 Sequoia and later include it.
- Zen browser’s bookmarks database: typically located under ~/Library/Application Support/zen/<profile>/places.sqlite.

## Installation
1.	Clone or download this workflow into your Alfred workflows folder.
2.	Ensure jq is available in your PATH.
3.	In Alfred → Workflows → this workflow:
	- Set the keyword trigger (default may be bm).
	- Configure secondary browser
	- (Optional) Set a hotkey for quick access.
4.	Ensure the script’s path to the Zen profile’s places.sqlite is correct (adjust if your profile folder is non-standard).

## Usage
* <kbd>z</kbd> Trigger the workflow
* <kbd>↩</kbd> Open bookmark in primary browser.
* <kbd>⇧</kbd><kbd>⌘</kbd><kbd>↩</kbd> Open in primary browser without closing Alfred.
* <kbd>⌘</kbd><kbd>↩</kbd> Open bookmark in secondary browser.
* <kbd>⌘</kbd><kbd>L</kbd> View all tags and full URL in Large Type.
* <kbd>⇧</kbd> Hold to show bookmark description.


### Notes & Limitations
- New bookmarks appear within about a minute: Alfred reuses results for 60 seconds while it reloads in the background
- Only the default Zen profile is indexed. If you use multiple profiles, set one as default via Zen’s Profile Manager
- The tag Exclude-Alfred (exactly that spelling and case) hides bookmarks from Alfred search results

## License

This fork is derived from [alfred-firefox-bookmarks](https://github.com/FireFingers21/alfred-firefox-bookmarks) by FireFingers21. Please refer to the original repository for its license and follow its terms when distributing your modified workflow.
