# `which-keyboard`

Get the keyboard ID for the next keyboard event.

In Linux you can easily change the options for a single keyboard using `setxkbmap -device <ID>`. But the ID is unpredictable, and changes every time you plug in or out another USB device, resetting the options. This script gets the keyboard ID of the next key pressed (or released, unless you're quick), making it really easy to set and re-set your options.

## Install

    sudo make install

## Use

Set options for a single keyboard easily:

    setxkbmap -device $(which-keyboard) -layout us -variant dvorak-alt-intl

## Test

Dependencies: `shellcheck`

    make

## Credits

- [How to get keyboard events by @ulidtko](https://unix.stackexchange.com/a/6231/3645)

## [License](LICENSE)

AGPL v3+
