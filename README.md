# Monstrous Media Homebrew Tap

Homebrew formulae for [Conductor](https://getconductor.app), the open-source
multi-protocol input mapping engine ([monstrous-media/conductor](https://github.com/monstrous-media/conductor)).

## Install

```sh
brew install monstrous-media/tap/conductor-daemon
```

This installs two binaries, prebuilt from the GitHub release (the macOS ones
are Developer ID signed and notarized):

- `conductor` — the mapping daemon
- `conductorctl` — the control CLI

Supported platforms: macOS (Apple Silicon and Intel) and Linux (x86_64).

Verify:

```sh
conductor --version
conductorctl --version
```

Uninstall:

```sh
brew uninstall conductor-daemon
brew untap monstrous-media/tap   # optional
```

> Naming note: the formula is `conductor-daemon` because the bare name
> `conductor` belongs to an unrelated Homebrew cask (conductor.build).

## Releasing a new version

Update the three `url`/`sha256` pairs (version is scanned from the URLs) in
`Formula/conductor-daemon.rb` from the new release's `.sha256` assets.
Tracked in [monstrous-media/conductor#79](https://github.com/monstrous-media/conductor/issues/79).

## License

MIT — see [LICENSE](LICENSE).
