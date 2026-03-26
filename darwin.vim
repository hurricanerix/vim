" ============================================================
" local.vim — macOS / iTerm2
" Symlink to ~/.vim/local.vim on macOS machines:
"   ln -s ~/.vim/darwin.vim ~/.vim/local.vim
" ============================================================

" Use macOS system clipboard for yank/paste
set clipboard=unnamed

" Apple Silicon: ensure Homebrew bin is in PATH for Vim's subshells
" Intel Macs use /usr/local/bin — change if needed
let $PATH = '/opt/homebrew/bin:/opt/homebrew/sbin:' . $PATH
