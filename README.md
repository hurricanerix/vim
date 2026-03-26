# .vim

My Vim configuration, works on macOS and Linux.

- `vimrc` — core config, shared across platforms
- `darwin.vim` — macOS overrides (symlinked to `local.vim` by `make`)
- `linux.vim` — Fedora/Linux overrides (symlinked to `local.vim` by `make`)
- `spell/` — personal word lists for English, Go, and C

## Setup

```bash
git clone git@github.com:hurricanerix/vim.git ~/.vim
cd ~/.vim
make
```

Detects the OS, symlinks the correct platform file, installs plugins, and installs Go binaries. Requires `go` to be installed before running.

```bash
make clean   # remove the local.vim symlink
```

---

# Vim Power User Commands

> Assumes you know basic navigation, `hjkl`, `:wq`, and modes. Everything here is beyond that.

---

## Text Objects — The Most Important Thing Here

The pattern: `operator` + `i`nside or `a`round + `object`

| Command | Effect |
|---------|--------|
| `ci"` | Change inside quotes — cursor anywhere in the string |
| `ci(` | Change inside parens |
| `ci{` | Change inside braces |
| `diw` | Delete word under cursor, wherever the cursor is on it |
| `dap` | Delete paragraph including surrounding blank lines |
| `dit` | Delete inside HTML/XML tag |
| `va{` | Visually select including the braces |
| `yip` | Yank inner paragraph |

Once you internalize these you stop navigating to delimiters manually.

---

## Motions Worth Learning

| Key | Move |
|-----|------|
| `f{char}` | Jump to next occurrence of char on current line |
| `t{char}` | Jump to just before char |
| `;` / `,` | Repeat / reverse last `f` or `t` |
| `%` | Jump to matching bracket/paren/brace |
| `{` / `}` | Jump by paragraph (blank line boundaries) |
| `H` / `M` / `L` | Cursor to top / middle / bottom of screen |
| `zz` | Center screen on cursor |
| `g;` / `g,` | Jump to previous / next change location |

---

## Registers

Vim has multiple clipboards. Most people only use the default and get burned by it.

| Register | Use |
|----------|-----|
| `"0p` | Paste last **yank** — unaffected by deletes |
| `"_d` | Delete to black hole — doesn't clobber default register |
| `"+y` / `"+p` | System clipboard yank / paste |
| `:reg` | Show all register contents |

**The common frustration:** you yank something, delete something else, paste — and get the wrong thing. `"0p` fixes this.

---

## Macros

| Command | Action |
|---------|--------|
| `q{a-z}` | Start recording into register |
| `q` | Stop recording |
| `@{a-z}` | Play macro |
| `10@a` | Play 10 times |
| `@@` | Replay last macro |

**Tips for reliable macros:** Start with `^` or `0` to anchor to line start. End with `j` so `10@a` auto-advances through 10 lines.

---

## The Dot Command

`.` repeats the last change. Massively underused.

1. `cw` + new word + `Esc`
2. `n` to next match
3. `.` to repeat

Reach for `.` before reaching for a macro.

---

## Visual Block — Column Select

`Ctrl-v` enters block mode.

- Select column → `I` → type → `Esc` — inserts on every line
- Select column → `$` → `A` → type → `Esc` — appends to every line
- Select block → `r{char}` — replaces every character in block

---

## Search & Replace

`:%s` is identical to `:1,$s` — three fewer keystrokes, use it instead.

```vim
:%s/foo/bar/g         " replace all in file (same as :1,$s)
:%s/foo/bar/gc        " replace all, confirm each — use this when unsure
:%s/\bfoo\b/bar/g     " whole word only
:%s/foo//gn           " count occurrences without replacing
```

Visual selection replace — select lines with `V`, then `:` auto-fills the range:
```vim
:'<,'>s/foo/bar/g
```

Reuse last search pattern — search with `*`, then:
```vim
:%s//replacement/g    " blank pattern reuses last search — no retyping
```

---

## Marks & Jumps

| Command | Action |
|---------|--------|
| `m{a-z}` | Set mark |
| `` `{mark} `` | Jump to exact mark position |
| `''` | Jump back to position before last jump |
| `` `. `` | Jump to last change |
| `Ctrl-o` / `Ctrl-i` | Jump back / forward through jump list |

---

## Spell Check & Dictionary

| Command | Action |
|---------|--------|
| `]s` / `[s` | Next / previous misspelling |
| `z=` | Suggest corrections for word under cursor |
| `zg` | Add word to personal dictionary |
| `zw` | Mark word as wrong |
| `zug` / `zuw` | Undo `zg` / `zw` |

Dictionary files are plain text, one word per line — edit directly to remove mistakes. After manual edits, rebuild the binary index:
```vim
:mkspell! ~/.vim/spell/en.utf-8.add
```

Three dictionaries are active depending on filetype: `en.utf-8.add` everywhere, `go.utf-8.add` in Go files, `c.utf-8.add` in C/H files. `zg` always writes to the filetype-specific dictionary.

---

## Useful Ex Commands

```vim
:t.               " duplicate current line
:m 42             " move current line to after line 42
:5,10t 20         " copy lines 5-10 to after line 20
:g/pattern/d      " delete all lines matching pattern
:v/pattern/d      " delete all lines NOT matching pattern
:%!clang-format   " pipe entire file through external formatter
:r !date          " insert shell command output at cursor
:earlier 5m       " revert buffer to state 5 minutes ago
```

---

## Toggles & State

| Command | What it does |
|---------|-------------|
| `:set paste` / `:set nopaste` | Disable / re-enable auto-indent during terminal paste |
| `:set paste!` | Toggle paste mode |
| `:set wrap!` | Toggle line wrapping |
| `:set spell!` | Toggle spell check (`<Leader>s` in vimrc) |
| `:set hlsearch!` | Toggle search highlighting |
| `:set list!` | Toggle whitespace markers |
| `:set cursorline!` | Toggle highlight on current line |

Most `set` options follow the same pattern — append `!` to toggle, prepend `no` to explicitly disable.

---

## Numbers

| Key | Action |
|-----|--------|
| `Ctrl-a` / `Ctrl-x` | Increment / decrement number under cursor |
| `10 Ctrl-a` | Add 10 to number |

---

## The Mental Model

Vim commands are a composable language: `verb + noun`

```
d  +  w       delete word
c  +  i"      change inside quotes
y  +  ap      yank a paragraph
>  +  G       indent to end of file
```

You don't memorize commands — you construct them. Learning more operators and text objects expands what you can express, not what you have to remember.
