" ============================================================
" CORE — shared across macOS and Linux
" ============================================================

set nocompatible               " Vim 9, not Vi
filetype plugin indent on      " required by vim-go and most plugins
syntax enable

set re=0

" --- Leader key ---
let mapleader = ","            " <Leader> = comma; change to space if preferred

" --- Line numbers ---
set number
set relativenumber

" --- Editing feel ---
set backspace=indent,eol,start
set scrolloff=8                " keep 8 lines visible above/below cursor
set sidescrolloff=8
set updatetime=300             " faster gitgutter refresh (default 4000ms is too slow)
set hidden                     " allow unsaved buffers in background
set signcolumn=yes             " always show sign column; prevents layout jump

" --- Indentation defaults (overridden per filetype below) ---
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent

" --- Search ---
set hlsearch                   " highlight matches
set incsearch                  " search as you type
set ignorecase                 " case-insensitive...
set smartcase                  " ...unless you type a capital letter

" --- Status line ---
set laststatus=2               " always show status line
set statusline=%f\ %m%r%h%w\ %{StatusGitBranch()}\ [%l/%L]\ col:%c

let g:git_branch_cache = ''

function! UpdateGitBranch()
  let l:branch = system("git -C " . expand('%:p:h') . " rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
  let g:git_branch_cache = len(l:branch) > 0 ? '(' . l:branch . ')' : ''
endfunction

function! StatusGitBranch()
  return g:git_branch_cache
endfunction

" Refresh only when switching buffers or regaining focus — not on every redraw
autocmd BufEnter,FocusGained * call UpdateGitBranch()

" --- Split behavior ---
set splitbelow                 " horizontal split opens below
set splitright                 " vertical split opens right

" --- Disable swap/backup clutter ---
set noswapfile
set nobackup
set nowritebackup

" --- Spell checker ---
set spelllang=en_us
" Base spellfile — global English dictionary, used for all files
set spellfile=~/.vim/spell/en.utf-8.add
" Spell check is OFF by default; toggle with <Leader>s
" Auto-enabled for markdown, text, and git commit messages (see below)

" Per-filetype dictionaries — layered on top of the global one
" zg adds words to the FIRST file in the list (the filetype-specific one)
autocmd FileType go
  \ setlocal spellfile=~/.vim/spell/go.utf-8.add,~/.vim/spell/en.utf-8.add
autocmd FileType c,cpp
  \ setlocal spellfile=~/.vim/spell/c.utf-8.add,~/.vim/spell/en.utf-8.add

" --- Whitespace display (subtle) ---
set list
set listchars=tab:›\ ,trail:·,extends:›,precedes:‹
" tab:   visible only on real tab characters (normal in Go files)
" trail: dots on trailing spaces — the important one
" Normal spaces between words are NOT shown

" ============================================================
" PLUGINS
" ============================================================

call plug#begin('~/.vim/plugged')

" Go — handles goimports on save, gopls go-to-def, highlighting
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" C — lightweight LSP client for go-to-declaration via clangd
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

" Git gutter — +/~/- markers in sign column
Plug 'airblade/vim-gitgutter'

" Color scheme — tokyonight light and dark variants
Plug 'hurricanerix/tokyonight-vim'

call plug#end()

" ============================================================
" COLOR SCHEME — OS light/dark aware
" ============================================================

set termguicolors              " required for true-color schemes

function! SetColorScheme()
  let l:dark = 1               " default to dark

  if has('mac') || $TERM_PROGRAM ==# 'iTerm.app'
    " macOS: query system preference
    let l:result = system("defaults read -g AppleInterfaceStyle 2>/dev/null")
    let l:dark = (l:result =~? 'dark') ? 1 : 0
  else
    " Linux/KDE Plasma: read active color scheme name
    let l:result = system("kreadconfig5 --group General --key ColorScheme 2>/dev/null")
    if l:result =~? 'light' || l:result =~? 'breeze$'
      let l:dark = 0
    endif
    " Fallback: try gsettings (GNOME / some KDE environments)
    if l:dark == 1
      let l:gtk = system("gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null")
      if l:gtk =~? 'light'
        let l:dark = 0
      endif
    endif
  endif

  if l:dark
    set background=dark
    let g:tokyonight_style = 'night'   " 'night' (darker) or 'storm' (softer dark)
  else
    set background=light
    let g:tokyonight_style = 'day'
  endif

  let g:tokyonight_enable_italic = 1
  colorscheme tokyonight
endfunction

call SetColorScheme()

" Re-detect when Vim gains focus (catches OS theme changes mid-session)
autocmd FocusGained * call SetColorScheme()

" ============================================================
" GO — vim-go
" ============================================================

let g:go_def_mode    = 'gopls'
let g:go_info_mode   = 'gopls'

" goimports on save: formats code AND manages imports automatically
let g:go_fmt_command  = 'goimports'
let g:go_fmt_autosave = 1

" Disable features not requested (keeps startup and saves snappy)
let g:go_code_completion_enabled = 0
let g:go_auto_type_info          = 0

" Syntax highlighting
let g:go_highlight_types              = 1
let g:go_highlight_fields             = 1
let g:go_highlight_functions          = 1
let g:go_highlight_function_calls     = 1
let g:go_highlight_operators          = 1
let g:go_highlight_extra_types        = 1

" Go indentation: tabs, width 4 (matches gofmt output)
autocmd FileType go setlocal noexpandtab tabstop=4 shiftwidth=4

" Go-to-declaration
autocmd FileType go nmap <silent> gd <Plug>(go-def)
autocmd FileType go nmap <silent> gD <Plug>(go-def-split)

" ============================================================
" C — vim-lsp + clangd
" ============================================================

if executable('clangd')
  autocmd User lsp_setup call lsp#register_server({
    \ 'name': 'clangd',
    \ 'cmd': {server_info -> ['clangd', '--background-index']},
    \ 'allowlist': ['c', 'cpp'],
    \ })
endif

" Go-to-declaration
autocmd FileType c,cpp nmap <silent> gd :LspDefinition<CR>
autocmd FileType c,cpp nmap <silent> gD :LspPeekDefinition<CR>

" Minimal LSP UI — navigation only, no diagnostics, no popups
let g:lsp_diagnostics_enabled         = 0
let g:lsp_document_highlight_enabled  = 0
let g:lsp_signature_help_enabled      = 0
let g:lsp_hover_ui                    = 'preview'

" C indentation: 4 spaces
autocmd FileType c,cpp setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4

" ============================================================
" GIT GUTTER
" ============================================================

let g:gitgutter_enabled        = 1
let g:gitgutter_sign_added     = '▎'
let g:gitgutter_sign_modified  = '▎'
let g:gitgutter_sign_removed   = '▁'
let g:gitgutter_realtime       = 1
let g:gitgutter_eager          = 1

" ============================================================
" SPELL CHECKER
" ============================================================

" Auto-enable for prose filetypes
autocmd FileType markdown,text,gitcommit setlocal spell

" Toggle spell check
nnoremap <Leader>s :setlocal spell!<CR>

" ============================================================
" KEY BINDINGS
" ============================================================

" Clear search highlight
nnoremap <Leader><space> :nohlsearch<CR>

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Jump back after go-to-def (works for both Go and C)
nnoremap <Leader>b <C-o>

" ============================================================
" PLATFORM OVERRIDES
" ============================================================

if filereadable(expand('~/.vim/local.vim'))
  source ~/.vim/local.vim
endif
