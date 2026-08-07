# Julideorg Homebrew tap

Homebrew packages for [julIDE](https://github.com/Julideorg/JulIde), an IDE for the
[Julia](https://julialang.org/) programming language.

## Install

```bash
brew tap Julideorg/tap
brew install --cask julide
```

Upgrades are handled by julIDE itself (it ships an in-app updater), so the cask is
marked `auto_updates true` and `brew upgrade` will leave it alone.

To remove it:

```bash
brew uninstall --cask julide
brew zap --cask julide     # also deletes settings, caches and saved state
```

## You also need Julia

julIDE does not bundle Julia. Install Julia 1.6 or newer — either with Homebrew:

```bash
brew install julia
```

or with [juliaup](https://github.com/JuliaLang/juliaup). julIDE probes
`/opt/homebrew/bin/julia`, `~/.juliaup/bin/julia`, `$JULIA_PATH` and your login shell's
`PATH`, so both are found automatically. Git tokens are stored in your login keychain,
and `brew zap` deliberately leaves those alone.

## Why a separate tap, and why it clears the quarantine flag

julIDE is not yet code-signed or notarized. Homebrew removed the `--no-quarantine` flag
in 5.1 and is dropping unsigned casks from `homebrew/cask` entirely on 2026-09-01, so a
third-party tap is the only way to ship julIDE through Homebrew today.

Left alone, Homebrew's quarantine attribute makes Gatekeeper refuse to launch the app.
The cask therefore runs `xattr -dr com.apple.quarantine` on the installed bundle in a
`postflight` step and prints a caveat saying it did. If you would rather Gatekeeper stay
in charge, install the `.dmg` from the
[releases page](https://github.com/Julideorg/JulIde/releases) instead and decide for
yourself.

Both the `postflight` block and this section go away once julIDE is signed and notarized.

## Maintenance

`.github/workflows/bump-cask.yml` runs daily, finds the newest *published* JulIde
release, downloads both DMGs, and commits the new version and checksums. After
publishing a release you can skip the wait:

```bash
gh workflow run bump-cask.yml --repo Julideorg/homebrew-tap
```

`.github/workflows/ci.yml` runs `brew style`, `brew audit`, and a real
`brew install --cask` smoke test on a macOS runner for every push and pull request.

## License

MIT, same as julIDE.
