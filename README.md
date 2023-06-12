## QuickLaunch: Instant URL & Bookmark Access for Chromium Browsers
a program to quickly launch URLs, bookmarked tabs and previously searched website in a 
chromium based browser

![Gif](./demo.gif)

## Elevator Pitch

Have you ever found an intriguing website, decided to bookmark it, only to see your bookmark list transform into an unruly maze over time? Picture this: bookmarks spilling way past the sidebar, forcing you to click, expand, and scour for that one website you want. Your digital real estate becomes a wilderness you're constantly taming.

How about this? You want to look something up on YouTube without the hassle of navigating to the website and inputting your search there. A simple, fast way to dive directly into your desired content – isn't that what you'd prefer?

Or perhaps, you've unknowingly opened multiple tabs of your favorite website, say foobar.com. By day's end, you're confronted with ten duplicate tabs. Now you're stuck sifting through your crowded browser, deciding whether to purge those excess tabs or let the icons shrink into obscurity.

If any of this sounds familiar, QuickLaunch may just be your digital savior. It's a solution designed to keep your bookmarks, your tabs, under control effortlessly. Better still, QuickLaunch is as free as freedom.

Quicklaunch comes equipped with these functionalities:
- Enables you to reach your saved tabs just by inputting the title of your bookmark.
- Employs search bangs such as !yt. For instance, typing "Brian Kernighan !yt" will prompt a search for "Brian Kernighan" on YouTube.
- Allows you to rapidly transition to active tabs in case your search query matches something already open in a tab.


<!-- ## Table of content -->

<!-- - [Installation](#installation) -->
<!-- - [Tutorials](#tutorials) -->

## Installation

**Dependencies include rofi, jq, chromix-too, and any chromium based browser**
You will also need to have sqlite3, but this is typically installed alongside 
your browser, if it is not then install it separately

### Easily installed applications

#### Archlinux (btw)

rofi

```
Pacman -S rofi
```

jq
```
Pacman -S jq
```

#### macOS

macOS's compatibility is still under development, so it does not work on it yet.

Unfortunately macOS does not have rofi another alternative is [choose](https://github.com/chipsenkbeil/choose),
which you can install by using homebrew:

```
brew install choose-gui
```

jq

```
brew install jq
```

### Installing chromix-too

```
sudo npm install -g chromix-too
```

For more information please follow chromix-too original [GitHub repo](https://github.com/smblott-github/chromix-too)

Now chromix-too also need to have a Chromium extension installed to work

Clone the repository above, then find the folder extension. The extension is written in coffee script, so we need to convert it to javascript first

To do this we need decaffinate:

```
npm install -g decaffeinate
```
or 
```
yarn global add decaffeinate
```
```
cd chromix-too/extension
decaffinate .
```

Then go to your browser extension manager, by clicking manage extension

Load unpack the folder extension after it has been converted to javascript, you 
will need to be in developer mode for this.

Finally, you will need to run the chromix-too-server in the background to use
the chromix-too client:

For Unix-like OS
```
chromix-too-server &
```

### Setting the correct paths
At the top of the launcher file:

```bash
BROWSER_BIN="/usr/bin/brave"
CHROMIX_TOO_BIN="$HOME/.nvm/versions/node/v16.17.0/bin/chromix-too"
ROOT_BROWSER_PATH="$HOME/.config/BraveSoftware/Brave-Browser"
BOOKMARKS="$ROOT_BROWSER_PATH/Default/Bookmarks"
HISTORY_DB="$ROOT_BROWSER_PATH/Default/History"
SEPARATOR="XXXXXXXXXXXXXXXXXXXX"
```

- BROWSER_BIN is the absolute path to the binary file to open your browser
- CHROMIX_TOO_BIN is the absolute path to the binary of chromix-too
- ROOT_BROWSER_PATH is the absolute path to the root folder of your browser, in the example above it is brave browser
- BOOKMARKS and HISTORY_DB typically does not need to be set once you got the root folder path correct
- SEPARATOR is just the symbols the script use to delineate between each sections of the choices


<!-- ## Tutorials -->

Type launcher.sh -h for all the possible options with the script:

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

Once an input phrase has been provided the script will present the result in 
three sections:

SEPARATOR\
Existing tabs (always have an id number at the beginning)\
SEPARATOR\
Bookmarks\
SEPARATOR\
History, past searches (format: web name # URL)
