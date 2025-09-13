# Neovim Config — R + Quarto, Blink, Iron, TokyoNight

Purpose‑built Neovim configuration for R and Quarto, built on LazyVim but trimmed and tuned for a fast, stable workflow in Kitty.

Highlights
- Completion: Blink (LazyVim default) for low‑latency LSP completion.
- REPL: iron.nvim with radian→R fallback, right/bottom split toggles.
- Quarto: quarto‑nvim + otter.nvim (LSP inside R chunks), chunk motions and chunk/paragraph send.
- R LSP: languageserver via base R; diagnostics disabled initially to avoid lintr/callr instability.
- Formatting: conform.nvim + styler on save (and conservative on‑the‑fly).
- Theme: tokyonight (default style: night) + quick cycle/transparent toggles.
- Quality of life: R operator macros (jj → <-, kk → |>), tidy RStudio‑style section headers, Save As with tab completion, soft wrap for prose, quick REPL/source switching.

Requirements
- Neovim 0.10+
- R (with packages): languageserver, styler, callr, lintr (optional)
- Optional: radian (recommended REPL)
- Terminal: Kitty (recommended; config tuned for it)

Install
1) Clone/symlink into your config path
   - macOS/Linux: `~/.config/nvim`
   - Windows (WSL): `~/.config/nvim`

   Example:
   - Move existing config aside (optional): `mv ~/.config/nvim ~/.config/nvim.bak`
   - Clone your repo here: `git clone git@github.com:<you>/nvim.git ~/.config/nvim`

2) Start Neovim and install plugins
   - Open Neovim → `:Lazy sync` → restart Neovim

3) R packages
   - In R: `install.packages(c("languageserver","styler","callr","lintr"))`
   - Diagnostics from R’s languageserver are disabled by default (see below).

Key Mappings (essentials)
- REPL
  - `<space>rs`: toggle REPL (defaults to right split)
  - `<space>rv` / `<space>rb`: open/toggle REPL right/bottom
  - `<space>rr`: restart REPL, `<space>rf`: focus, `<space>rh`: hide
  - `<space>sl`: send line, `<space>sc`: send motion/visual, `<space>sp`: send paragraph, `<space>sf`: send file
  - In terminal: `<space>rp` jumps back to previous (source) window, `Esc` exits terminal mode

- Quarto / Markdown
  - `]]` / `[[`: next/previous code chunk
  - `<leader>rc`: run current R chunk
  - In prose buffers, `<space>sl` and `<space>sp` send only when cursor is inside an R chunk

- R operators
  - Insert mode: `jj` → ` <- `, `kk` → ` |> `

- Section headers (RStudio‑style and more)
  - Normal: `<leader>r1` / `r2` / `r3` → `#/##/### Title ----` with tidy spacing, cursor enters insert
  - Underline: `<leader>r-` (dashes), `<leader>r=` (equals)
  - Boxed: `<leader>rB` thin box, `<leader>rH` heavy box
  - Visual: same keys convert selection into a header block

- Save As
  - `<leader>sA`: Save As… with Tab path completion; accepts directory then prompts for filename; creates parents

- Theme
  - Default: TokyoNight “night”
  - `<leader>ut`: cycle style (storm/night/moon/day)
  - `<leader>uT`: toggle transparent

R LSP & diagnostics
- languageserver is started via `R --slave -e "options(languageserver.diagnostics=FALSE);languageserver::run()"` to avoid `lintr`/`callr` issues. Re‑enable later by removing that option and optionally adding a quiet `~/.lintr`.

Quarto notes
- This config uses otter.nvim so LSP works inside R chunks in `.qmd`/`.Rmd`.
- Code execution is handled via iron.nvim; Quarto’s codeRunner integrations are disabled to avoid extra dependencies.

Kitty notes
- Fonts: JetBrainsMono Nerd Font, size 14 (see `~/.config/kitty/kitty.conf`).
- Alt key is mapped to pass through for R operators; REPL runs in Neovim split (no external terminal needed).

Versioning & GitHub
- This folder is a git repo; commit and push to your GitHub `nvim` repo:

```
cd ~/.config/nvim
git remote remove origin 2>/dev/null || true
git remote add origin git@github.com:<you>/nvim.git
git branch -M main
git add -A
git commit -m "Neovim config: R + Quarto + Iron + Blink + TokyoNight"
git push -u origin main
```

Updating
- Update plugins: `:Lazy sync`
- Update R packages as needed; re‑enable diagnostics when stable if desired.
