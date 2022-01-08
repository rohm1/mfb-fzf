# Minimal file browser

MFB (minimal file browser) is a [fzf](https://github.com/junegunn/fzf/) powered
bash app to quickly navigate through the filesystem. Initially planned as a
rewrite of my [python version](https://github.com/rohm1/mfb), I extended it a
bit after I discovered how cool fzf is.

## Install

```
git clone https://github.com/rohm1/mfb-fzf.git
echo "source /path/to/mfb-fzf/mfb.sh" >> ~/.bashrc
```
and use the `mfb` command.

## Special keys

| key    | action |
|--------|--------|
| ctrl-c | exit   |
| ctrl-d | exit   |
| esc    | exit   |
| ctrl-q | exit and change your shell path to the last selected path   |
| ctrl-e | open the highlighted file in editor   |
| ctrl-s | print the name of the highlighted file/directory to stdout and exit. useful for scripting, e.g. `cat $(mfb)`  |
| ctrl-t | toggle preview  |

## Special inputs

| input     | action |
|-----------|--------|
| / + enter | go to / |
| ~ + enter | go to home |
| .. + enter | go .. |

## Params

| Param | Env var           | description |
|-------|-------------------|-------------|
| -l    | MFB_LS_OPTIONS    | changes options for `ls` |
| -i    | MFB_LINE_INDEX    | if you change `MFB_LS_OPTIONS` you'll need to change it accordingly |
| -s    | MFB_LINES_TO_SKIP | if you change `MFB_LS_OPTIONS` you'll need to change it accordingly |
| -p    | MFB_SHOW_PREVIEW  | set it to `0` to disable preview |

Env vars will be evaluated first, and then the CLI args, thus CLI args override env vars.
