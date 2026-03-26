" ============================================================
" local.vim — Fedora 43 / KDE Plasma
" Symlink to ~/.vim/local.vim on Linux machines:
"   ln -s ~/.vim/linux.vim ~/.vim/local.vim
" ============================================================

" Linux clipboard — uses the + register (Ctrl+C/Ctrl+V in other apps)
" Requires vim-X11: sudo dnf install vim-X11
" Check support: vim --version | grep clipboard
" If -clipboard appears, see setup.md section 13 for the fix.
set clipboard=unnamedplus

" Go binaries installed to ~/go/bin
let $PATH = $HOME . '/go/bin:' . $PATH
