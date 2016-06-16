# fuzzy-search-and edit

It's a plugin for zsh, which offers widget for fuzzy searching and instantly
opening matched file on matched line.

![fuzzy-search-and-edit](https://cloud.githubusercontent.com/assets/674812/16118621/c23d6986-33f9-11e6-84d6-2a9082a0484f.gif)

# Requirements

* [fzf](https://github.com/junegunn/fzf);
* [zsh-async](https://github.com/junegunn/fzf);

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
