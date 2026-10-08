# henryyu333/tap

Homebrew tap for [mss](https://github.com/henryyu333/mss) — search your AI coding history, on demand.

`Formula/mss.rb` is the source formula for the published **v0.3.0** release,
published verbatim from the release pipeline's generated artifact. It builds
`mss` from the exact tagged source archive (`mss_0.3.0_source.tar.gz`, SHA-256
`0f5a2b2b624d93d3efced289a9b0a2892af97eeaf579badc40703175040c8a78`) with
`go build`, using the same flags the release binaries use (`CGO_ENABLED=0`,
`-trimpath`, `-s -w`, `-X main.version=0.3.0`). For future releases, publish the
release-generated `mss.rb` the same way; do not hand-edit its version/URL/SHA
lines.

```sh
brew install --formula henryyu333/tap/mss
```

The formula has no bottle yet, so Homebrew builds from source either way;
`--build-from-source` makes that explicit and is safe to add.

## Runtime tools (optional, user-installed)

The formula deliberately ships no runtime dependencies. mss discovers
optional CLIs on `PATH` at run time: `sqlite3` reads SQLite-backed stores
(opencode, Cursor IDE, Grok) — macOS ships `/usr/bin/sqlite3` — and `zstd`
reads zstd-compressed transcripts (newer Codex rollouts, DeepSeek Harness),
installed with `brew install zstd`. Without them mss still runs and
`mss doctor` names the stores it could not read.

## The mss skill

The formula never installs the agent skill automatically and writes nothing
outside the keg. Install it explicitly from the installed binary:

```sh
mss install-skill <claude|codex|pi|omp> [--language en|zh-CN]
```

Installation is version-matched to the binary, needs no network, refuses to
overwrite differing existing files, and does not edit agent settings.

## Migrating from the `mss` cask

This tap used to ship a `mss` cask that installed the prebuilt binary. If you
installed it (`brew list --cask mss` shows it), migrate to the formula. The
formula replaces the binary only — it does not touch your index
(`~/.cache/mss/`), settings (`~/.config/mss/`), or any skills you installed
under your agent's skills directory.

The stages below are ordered so the current `mss` keeps working until the
replacement is built and proven:

```sh
# 0. Record the state you're migrating away from: the installed version,
#    which binary PATH resolves, and a backup of the cask's recorded
#    artifacts (the metadata Homebrew saved at cask install time).
brew list --cask --versions mss
command -v mss && mss version
backup="$(mktemp -d "$HOME/mss-cask-backup.XXXXXX")"
cp -R "$(brew --caskroom)/mss" "$backup/mss"

# 1. Build and install the formula WITHOUT linking — the installed cask is
#    untouched and `mss` still runs its binary.
brew install --formula --build-from-source --skip-link henryyu333/tap/mss

# 2. Prove the new build. `--force` runs the formula's test block against the
#    unlinked keg; the opt-prefix path resolves to the installed keg even
#    before linking.
brew test --force henryyu333/tap/mss
"$(brew --prefix henryyu333/tap/mss)/bin/mss" version    # expect: mss 0.3.0

# 3. Only now retire the cask. Plain uninstall — no --zap (there is nothing
#    to zap and --zap would delete user data anyway) and no --force.
brew uninstall --cask mss

# 4. Link the formula and verify PATH resolution.
brew link mss
command -v mss    # expect: $(brew --prefix)/bin/mss
mss version       # expect: mss 0.3.0
```

Notes:

- A formula and cask of the same name coexist in Homebrew — they are tracked
  separately (Cellar vs Caskroom). The `--skip-link` install above is the
  supported way to stage the formula while the cask still owns the `mss`
  symlink; nothing automatic migrates an installed cask to a formula.
- Homebrew retains the Cask's install metadata for later `brew uninstall --cask`
  even after its tap definition is removed. The actual Cask uninstall/link
  cutover is not yet exercised: local validation deliberately preserves the
  existing Cask. Retain the backup from step 0 and invoke its old binary by full
  path if rollback is needed; do not force prefix symlinks or reinstall the old
  quarantine-removing Cask.
- If the formula build or test fails, `brew uninstall --formula mss` removes
  only the staged keg; the cask keeps working.

## Upgrading / uninstalling the formula

```sh
brew update && brew upgrade --formula henryyu333/tap/mss
brew uninstall --formula henryyu333/tap/mss
```

Uninstalling leaves your index, settings and skills in place — mss keeps its
state under your home directory, not in the Homebrew prefix.
