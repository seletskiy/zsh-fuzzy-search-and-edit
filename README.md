# fuzzy-search-and edit

It's a plugin for zsh, which offers widget for fuzzy searching and instantly
opening matched file on matched line.

![fuzzy-search-and-edit](https://cloud.githubusercontent.com/assets/674812/16119705/79da30a2-33fe-11e6-9827-416c961a8b5f.gif)

# Requirements

* [fzf](https://github.com/junegunn/fzf);
* [zsh-async](https://github.com/mafredri/zsh-async);

# Installation

## Via zgen

```fzf
zgen load mafredri/zsh-async
zgen load seletskiy/zsh-fuzzy-search-and-edit
```

# Usage

```fzf
bindkey '^P' fuzzy-search-and-edit
```
