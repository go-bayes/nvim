# python setup for neovim

This document explains how Python support in Neovim is structured so that it coexists safely with your R/Rmd/Qmd tooling.

## overview

There are three layers:

1. **System Python (Homebrew /opt/homebrew/bin/python3)** – used for Neovim’s Python host and for installing command-line tools with `pipx`.
2. **Editor host packages** – `pynvim` lives in your user site-packages so Neovim can embed Python.
3. **Per-project environments** – created with `uv venv .venv` inside each Python project so code, REPL, and LSP all use the project’s dependencies (mirrors how `renv` isolates R packages). Nothing here touches R workflows.

## requirements

- Python 3.10+ (currently 3.14.0 from Homebrew at `/opt/homebrew/bin/python3`)
- `pipx` on your PATH (`brew install pipx`)
- `uv` (installed automatically by the setup script via `pipx`, or manually with `pipx install uv`)

## installation protocol

### quick setup

Run the automated script to provision the shared tooling once:

```bash
~/.config/nvim/scripts/setup_python.sh
```

The script:
1. Checks `python3`, `pipx`, and records the interpreter path.
2. Upgrades `pip` in the user site-packages.
3. Installs host packages from `python-requirements.txt` (currently just `pynvim`).
4. Installs CLI tools (`ipython`, `pyright`, `ruff`, `uv`) using `pipx --python "$(which python3)"`.
5. Prints versions so you can confirm everything worked.

### manual host install (rare)

If you want to bootstrap without the script:

```bash
python3 -m pip install --user -r ~/.config/nvim/python-requirements.txt
pipx install ipython --python "$(which python3)"
pipx install pyright --python "$(which python3)"
pipx install ruff --python "$(which python3)"
pipx install uv --python "$(which python3)"
```

## per-project environments with uv

Create one `.venv` per Python project. This mirrors `renv` and keeps packages out of your R libraries.

```bash
cd /path/to/project
uv venv .venv                     # creates .venv tied to project
source .venv/bin/activate
uv pip install ipython ipdb ruff black pytest debugpy  # plus project deps
uv pip freeze > requirements.txt  # optional lockfile
```

- Pyright (`lua/plugins/python-lsp.lua`) automatically picks up `.venv`.
- `iron.nvim` prefers `.venv/bin/ipython`, so installing `ipython` in the env keeps the REPL aligned with your project imports.
- Each project can pin different Python versions by creating the venv with `uv venv --python <path> .venv`.

## required packages

`python-requirements.txt` intentionally only lists:

- **pynvim** – Neovim’s Python host (installed with `python3 -m pip --user`).

Everything else lives either in pipx (CLI tooling shared by all projects) or inside each `.venv`.

### pipx-managed CLI tools
- **ipython** – interactive REPL fallback when no project env exists.
- **pyright** – Language Server Protocol implementation.
- **ruff** – formatter and linter (Conform uses `ruff_format`/`ruff_organize_imports`).
- **uv** – fast package/venv manager for per-project workflows.

### per-project installs (via `uv pip`)
- **ipython/ipdb** – so the project REPL uses local deps.
- **ruff**, **black**, **pytest**, **debugpy**, **jupyter**, and your application dependencies.

## verification

```bash
# host provider
python3 -c "import pynvim; print(pynvim.__version__)"

# pipx tools
ipython --version
pyright --version
ruff --version
uv --version

# Neovim sees python
nvim --headless -c 'checkhealth provider' -c 'quit'
```

Inside a project (`source .venv/bin/activate`):

```bash
which python         # should point to project/.venv/bin/python
ipython --version    # ensures REPL is using the env you expect
nvim .               # :LspInfo should list the .venv path
```

## iron.nvim REPL

The Python entry in `lua/plugins/iron-r.lua` tries these in order:
1. `.venv/bin/ipython --no-autoindent`
2. `venv/bin/ipython`
3. global `ipython`
4. `python3`

So once you add `.venv` + `ipython` to a project, Iron will automatically target the right interpreter without touching your R configuration.

## python version management

The host interpreter comes from Homebrew:
- Path: `/opt/homebrew/bin/python3`
- Current: 3.14.0

To switch versions:
1. `brew install python@3.x`
2. `brew link python@3.x`
3. Re-run `~/.config/nvim/scripts/setup_python.sh` so pipx tools are rebuilt against the new Python.
4. Recreate project venvs with `uv venv --python /opt/homebrew/bin/python3 .venv` if they need the newer version.

## troubleshooting

### pipx tool using old Python
`pipx reinstall <tool> --python "$(which python3)"` for each of `ipython`, `pyright`, `ruff`, `uv`.

### Neovim can’t find python
`nvim --headless -c 'echo exepath("python3")' -c 'quit'`

### Project import errors
Confirm `.venv` exists and has packages: `source .venv/bin/activate && python -m pip list`.

### REPL not working
1. `which ipython` (inside the project)
2. `:IronRepl` and `:messages` in Neovim for errors
3. `:PyEnsureRepl` to force a restart

## keeping R workflows safe

All Python-specific autocmds and plugins are scoped to `filetype == "python"` or directories containing `.py`. R, Rmd, Qmd buffers continue using `radian`, `r-languageserver`, `styler`, etc. Creating `.venv` folders and installing Python packages inside them has no effect on your R libraries or `renv` snapshots.

## keybindings (python buffers)

- `<space>rs` – Start/toggle REPL
- `<space>rb` / `<space>rv` – Bottom or right split REPL
- `<space>rr` – Restart REPL
- `<space>sl` / `<space>sc` / `<space>sf` / `<space>sp` – Send line / selection / file / paragraph
- `<space>s<space>` – Interrupt running code

See `lua/plugins/iron-r.lua` for the complete list.
