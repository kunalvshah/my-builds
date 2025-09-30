# Vim Developer Setup Guide

This document contains your **minimal but powerful `.vimrc`** configuration for Python, HTML, ReactJS, JavaScript, TypeScript, CSS, and Nginx, along with installation instructions.

## `.vimrc` Configuration

```vim
" ================= Basic Vim Settings =================
set nocompatible            " Disable vi compatibility
set number                  " Show absolute line numbers
set relativenumber          " Show relative line numbers
set cursorline              " Highlight current line
set showmatch               " Show matching brackets
set ignorecase              " Case-insensitive search
set smartcase               " Case-sensitive search when uppercase present
set incsearch               " Incremental search
set hlsearch                " Highlight search matches
set wildmenu                " Enhanced command-line completion
set history=1000            " Command history size
set undofile                " Persistent undo
set backspace=indent,eol,start

" ================= Plugin Manager =================
call plug#begin('~/.vim/plugged')

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

" coc.nvim language servers for your stack
let g:coc_global_extensions = [
\   'coc-json',
\   'coc-tsserver',
\   'coc-html',
\   'coc-css',
\   'coc-pyright'
\]

" Rainbow parentheses
let g:rainbow_active = 1

" Convenience mapping to clear search highlight
nnoremap <SPACE> :nohlsearch<CR>
```

---

## Installation Instructions

### 1. Install vim-plug

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

### 2. Save `.vimrc`

```bash
nano ~/.vimrc
```
Paste the configuration above, then save and exit.

### 3. Install Plugins

Open Vim:
```vim
:PlugInstall
```

### 4. Restart Vim

Close and reopen Vim to apply changes.

---

## Why This Config Works Well

- **Minimal**: Keeps Vim lightweight.
- **Language coverage**: Includes Python, HTML, ReactJS, JS, TS, CSS, Nginx.
- **Developer friendly**: Adds linting, autocomplete, syntax highlighting.
- **Readability**: Rainbow brackets for easier navigation.

---

## Optional Enhancements

- Add **NERDTree** for file browsing.
- Add **vim-airline** for an enhanced status bar.
- Add **fzf.vim** for fuzzy file searching.

These can be added later as needed.
