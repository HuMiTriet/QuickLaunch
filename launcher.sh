#!/bin/bash
# dependencies: rofi, jq, brave, sqlite3, chromix-too
#
BROWSER_BIN="/usr/bin/brave"
CHROMIX_TOO_BIN="$HOME/.nvm/versions/node/v16.17.0/bin/chromix-too"
ROOT_BROWSER_PATH="$HOME/.config/BraveSoftware/Brave-Browser"
BOOKMARKS="$ROOT_BROWSER_PATH/Default/Bookmarks"
SEPARATOR="XXXXXXXXXXXXXXXXXXXX"

# decide if the browser should be open in a new instance or not
while getopts 'twh' OPTION; do
	case "$OPTION" in
	w)
		BROWSER_ARGS="--new-window"
		BROWSER_DISPLAY_TEXT="open in new (window): "
		;;
	t)
		BROWSER_ARGS="--new-tab"
		BROWSER_DISPLAY_TEXT="open in new (tab): "
		;;
	h)
		echo "Script to quickly launch urls in a browser (please change all of the 
    arguments at the top of the bash file before use)
    -t: opens the url in a new tab in the existing window
    -w: opens the url in a completely new window
    -h: display this help prompt again and exit

    **BANGS**
    Scenario you want to search for min-max heap on wikipedia:

    min-max heap !w

    it will display the wikipedia page for min-max heap on the browser
    **Bangs must be put at the end to work !**

    There are some existing builtin search bangs:

    !g:    google
    !gt:   google translate
    !yt:   youtube 
    !aw:   archlinux wiki
    !w:    wikipeadia
    !so:   stack overflow
    !mw:   merriam-webster
    !gist: github gist
    "
		exit 1
		;;
	?)
		echo "script usage: $(basename "$0") [-t] [-w] or [-h] for help" >&2
		exit 1
		;;
	esac
done

shift "$((OPTIND - 1))"

# Function to list existing tabs
list_existing_tabs() {
	"$CHROMIX_TOO_BIN" ls
}

# Function to read bookmarks
read_bookmarks() {
	local name url

	jq -r '.roots.bookmark_bar.children[] | (.name, .url)' "$BOOKMARKS" | while read -r name && read -r url; do
		echo -e "${name}\t${url}"
	done
}

# Function to read history
read_history() {
	local HISTORY_DB SQL histlist

	HISTORY_DB="$ROOT_BROWSER_PATH/Default/History"

	SQL="SELECT u.title, u.url FROM urls as u WHERE u.url LIKE 'https%' ORDER BY visit_count DESC;"
	histlist=$(printf '%s\n' "$(sqlite3 "file:$HISTORY_DB?mode=ro&nolock=1" "$SQL")" |
		awk -F "|" '{print $1" # "$NF} ')

	echo "$histlist"
}

launch_browser() {
	"$BROWSER_BIN" "$BROWSER_ARGS" "$1"
}

# Run the functions in parallel using background processes and process substitution
EXISTING_TABS=$(list_existing_tabs &)
BOOKMARKS_STR=$(read_bookmarks &)
HISTLIST=$(read_history &)

wait

# Process bookmarks
declare -A BOOKMARKS
while IFS=$'\t' read -r name url; do
	BOOKMARKS["$name"]="$url"
done <<<"$BOOKMARKS_STR"

choice=$(
	printf '%s\n' \
		"$SEPARATOR" \
		"${EXISTING_TABS[@]}" \
		"$SEPARATOR" \
		"${!BOOKMARKS[@]}" \
		"$SEPARATOR" \
		"$HISTLIST" |
		rofi -scroll-method 2 -normalize-match -matching normal -tokenize -dmenu -i -l 9 -p \
			"$BROWSER_DISPLAY_TEXT"
)

if [[ "$choice" = "$SEPARATOR" ]]; then
	launch_browser

elif [[ "$choice" =~ ^.+[[:space:]]{1,2}\![a-zA-Z]{1,2}$ ]]; then
	SEARCH_QUERY="${choice%!*}"
	SEARCH_ENG="${choice##* }"

	case "$SEARCH_ENG" in
	!g)
		launch_browser "https://google.com/search?hl=en&q=$SEARCH_QUERY"
		;;
	!gt)
		launch_browser "https://translate.google.com/?sl=auto&tl=en&text=$SEARCH_QUERY &op=translate"
		;;
	!yt)
		launch_browser "https://www.youtube.com/results?search_query=$SEARCH_QUERY"
		;;
	!aw)
		launch_browser "https://wiki.archlinux.org/index.php?search=$SEARCH_QUERY"
		;;
	!gh)
		launch_browser "https://github.com/search?o=desc&q=$SEARCH_QUERY&s=stars"
		;;
	!w)
		launch_browser "https://en.wikipedia.org/w/index.php?search=$SEARCH_QUERY"
		;;
	!so)
		launch_browser "https://stackoverflow.com/search?q=$SEARCH_QUERY"
		;;
	!mw)
		launch_browser "https://www.merriam-webster.com/dictionary/$SEARCH_QUERY"
		;;
	!gist)
		launch_browser "https://gist.github.com/search?q=$SEARCH_QUERY"
		;;
	esac

elif [[ "$choice" =~ .*'#'.* ]]; then
	url=$(echo "$choice" | awk '{print $NF}') || exit
	launch_browser "$url"

elif [[ $(echo "$choice" | awk '{print $1}') =~ ^[0-9]+$ ]]; then
	url=$(echo "$choice" | awk '{print $1}') || exit
	"$CHROMIX_TOO_BIN" focus "$url"

elif [[ ${BOOKMARKS["$choice"]} ]]; then
	launch_browser "${BOOKMARKS[$choice]}"

elif [[ -n "$choice" ]]; then
	url="https://google.com/search?hl=en&q=$choice"
	launch_browser "$url"
else
	exit 0
fi
