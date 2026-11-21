#!/bin/zsh --no-rcs

# Zen holds an exclusive lock on places.sqlite, so read a private snapshot
# (main file + WAL) refreshed only when Zen has written since the last one.

readonly releaseChannel="firefox"
readonly zenDir="${HOME}/Library/Application Support/zen"
readonly profile=$(awk -F= '/^Default=/ {print $2; exit}' "${zenDir}/installs.ini" 2>/dev/null)
readonly src="${zenDir}/${profile}/places.sqlite"
readonly cacheDir="${alfred_workflow_cache:-${TMPDIR}zenbookmarks}"
readonly db="${cacheDir}/places.sqlite"
readonly stamp="${cacheDir}/stamp"

readonly sqlQuery="SELECT p.id, p.url, b.title, p.description, JSON_GROUP_ARRAY(DISTINCT t.title) AS tag_names
FROM moz_places p
JOIN moz_bookmarks b ON b.fk = p.id
JOIN moz_bookmarks t ON t.id = b.parent
GROUP BY p.url;"

signature() { stat -f '%m %z' "${src}" "${src}-wal" 2>/dev/null }

refresh() {
	local tmp before
	mkdir -p "${cacheDir}"
	tmp=$(mktemp -d "${cacheDir}/tmp.XXXXXX") || return 1
	for _ in 1 2 3; do
		before=$(signature)
		cp "${src}" "${tmp}/places.sqlite" || break
		cp "${src}-wal" "${tmp}/places.sqlite-wal" 2>/dev/null
		# Retry if Zen wrote or checkpointed mid-copy (mismatched main/WAL pair)
		[[ "$(signature)" == "${before}" ]] || continue
		# Fold the WAL into the snapshot so it is a single self-contained file
		[[ "$(sqlite3 "${tmp}/places.sqlite" 'PRAGMA wal_checkpoint(TRUNCATE); PRAGMA journal_mode=DELETE; PRAGMA quick_check;' 2>/dev/null | tail -1)" == "ok" ]] || continue
		mv -f "${tmp}/places.sqlite" "${db}" && print -r -- "${before}" > "${stamp}"
		break
	done
	rm -rf "${tmp}"
}

[[ -r "${src}" && "$(signature)" != "$(<"${stamp}" 2>/dev/null)" ]] && refresh

if [[ ! -r "${db}" ]]; then
	print '{"items":[{"title":"Bookmarks unavailable","subtitle":"Cannot read the Zen bookmarks database","valid":false}]}'
	exit 0
fi

sqlite3 -json "file:${db}?mode=ro" "${sqlQuery}" | jq -s \
  --arg useDesc "$useDesc" \
  --arg useURL "$useURL" \
  --arg useTag "$useTag" \
  --arg releaseChannel "$releaseChannel" \
  --arg showAllTags "$showAllTags" \
  --arg useQL "$useQL" \
  --arg useKeyword "$useKeyword" \
'{
    "cache": { "seconds": 60, "loosereload": true },
    "items": (if (length > 0) then
      map(.[] |
        (if .tag_names | contains("Exclude-Alfred") then empty else
          {
            "uid": .id,
            "title": .title,
            "subtitle": "\(.tag_names | fromjson | .[1:] | if .[0] then "["+(if $showAllTags == "1" then join(", ") else .[0] end)+"] " else "" end)\(.url)",
            "arg": .url,
            "match": "\(.title) \(if $useURL == "1" then .url else "" end) \(if $useDesc == "1" then (.description // "") else "" end) \(if $useTag == "1" then (.tag_names | fromjson | .[1:] | map("#" + .) | join(" ")) else "" end) \(if $useKeyword == "1" then (.keyword // "") else "" end)",
            "quicklookurl": "\(if $useQL == "1" then .url else "" end)",
            "text": {
              "largetype": "[\(.tag_names | fromjson | .[1:] | join(", "))]\n\n\(.url)"
            },
            "icon": { "path": "images/\($releaseChannel).png" },
            "mods": {
              "cmd": {
                "subtitle": "⌘↩ Open in secondary browser",
                "arg": .url,
                "variables": { "bSecondary": true }
              },
              "shift": {
                "subtitle": (.description // "")
              }
            }
          }
        end)
      )
    else
      [
        {
          "title": "Search Bookmarks...",
          "subtitle": "You have no bookmarks",
          "valid": "false"
        }
      ]
    end)
}'