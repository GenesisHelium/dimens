<h1 align="center">Dimens</h1>

<p align="center">
Spinning 1D to 10D dimensions in your terminal.
</p>

https://github.com/user-attachments/assets/e5a24728-7279-4666-99a6-b0f1da67d01d

## Install

```bash
curl -fsSL -o /tmp/dimens https://raw.githubusercontent.com/GenesisHelium/dimens/main/dimens.sh && sudo install -Dm755 /tmp/dimens /usr/local/bin/dimens && rm -f /tmp/dimens
```

Then run `dimens`.

### No sudo?

Install for just your user:

```bash
curl -fsSL --create-dirs -o ~/.local/bin/dimens https://raw.githubusercontent.com/GenesisHelium/dimens/main/dimens.sh && chmod +x ~/.local/bin/dimens
```

Then add `~/.local/bin` to your PATH. Check your shell with `echo $SHELL`, then run the matching line:

| Shell | Run this |
| --- | --- |
| bash | `echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc` |
| zsh | `echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc` |
| fish | `fish_add_path ~/.local/bin` |

Run `dimens`.

### Required

| What is required? |
| --- |
| Requires bash 4+ and awk. |

### How to run it?

Run it by typing `dimens` in your graphical accelerated terminal. If you see boxes instead of lines, then run `DIMENS_ASCII=1 dimens`.

## Controls

- 1-9: switch dimensions, 0 is 10
- p: pause
- "+" / "-" : speed
- q: return to the menu

## Uninstall

Installed with sudo:

```bash
sudo rm -f /usr/local/bin/dimens
```

Installed for your user only:

```bash
rm -f ~/.local/bin/dimens
```

## Credits

- Eris (For supporting me making this project.)
- [Rickky](https://github.com/0-ss) (Inspired by his README macshell)
