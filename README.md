# fuzzy-search-and edit

It's a plugin for zsh, which offers widget for fuzzy searching and instantly
opening matched file on matched line.

![fuzzy-search-and-edit](https://cloud.githubusercontent.com/assets/674812/16119178/2c878e28-33fc-11e6-89a7-76b4b8b46ca6.gif)

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
