# Neovim Developer Setup Guide

This guide provides a **step-by-step setup for Neovim** specifically for Python, HTML, ReactJS, JavaScript, TypeScript, CSS, and Nginx. This setup is **completely separate from Vim** and does not reuse Vim configuration files.

---

## 1. Install Neovim

### On Ubuntu/Debian:

```bash
sudo apt update
sudo apt install neovim
```

### On Fedora:

```bash
sudo dnf install neovim
```

### On macOS:

```bash
brew install neovim
```

---

## 2. Install vim-plug for Neovim

```bash
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

---

## 3. Create Neovim Configuration Directory

```bash
mkdir -p ~/.config/nvim
```

---

## 4. Create `init.vim`

Open Neovim config file:

```bash
nvim ~/.config/nvim/init.vim
```

Paste the following configuration:

```vim
" ================= Basic Neovim Settings =================
set nocompatible
set number
set relativenumber
set cursorline
set showmatch
set ignorecase
set smartcase
set incsearch
set hlsearch
set wildmenu
set history=1000
set undofile
set backspace=indent,eol,start

" Enable true color support
if has('termguicolors')
  set termguicolors
endif

" ================= Plugin Manager =================
call plug#begin('~/.local/share/nvim/plugged')

" Syntax highlighting for many languages
Plug 'sheerun/vim-polyglot'

" Linting and fixing
Plug 'dense-analysis/ale'

" IDE-like autocompletion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Rainbow brackets
Plug 'luochen1990/rainbow'

call plug#end()

" ================= Plugin Settings =================

" ALE linting settings
let g:ale_linters_explicit = 1
let g:ale_fix_on_save = 1

" coc.nvim language servers
let g:coc_global_extensions = [
\   'coc-json',
\   'coc-tsserver',
\   'coc-html',
\   'coc-css',
\   'coc-pyright'
\]

" Rainbow parentheses
let g:rainbow_active = 1

" Clear search highlight mapping
nnoremap <SPACE> :nohlsearch<CR>
```

---

## 5. Install Plugins in Neovim

Open Neovim:

```vim
:PlugInstall
```

---

## 6. Restart Neovim

Close and reopen Neovim to apply the configuration.

---

## Why This Setup Works Well

* **Minimal**: Keeps Neovim fast.
* **Language coverage**: Python, HTML, ReactJS, JS, TS, CSS, Nginx.
* **Developer-friendly**: Adds linting, autocomplete, syntax highlighting.
* **Readability**: Rainbow brackets.
* **Separate from Vim**: Fully independent config.

---

## Optional Enhancements

Later you can add:

* **NERDTree** for file browsing.
* **vim-airline** for enhanced status bar.
* **fzf.vim** for fuzzy searching.

These can be added without interfering with the base configuration.
