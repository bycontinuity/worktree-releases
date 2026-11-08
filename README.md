# Worktree desktop releases

Downloads, update metadata and release notes for the Worktree desktop app. Application source is in a separate private repository. Worktree is built on OpenCode; upstream licenses and attributions still apply.

Latest: [v0.1.0-alpha.4](https://github.com/bycontinuity/worktree-releases/releases/tag/v0.1.0-alpha.4). All releases: [Releases](https://github.com/bycontinuity/worktree-releases/releases). Every release is a pre-release (alpha). Keep your projects backed up.

## Install

`<version>` is the tag without the `v`, e.g. `0.1.0-alpha.4`.

| Platform | Asset | Notes |
|---|---|---|
| Windows x64 | `worktree-<version>-win-x64.exe` | Unsigned; Windows will show an unknown-publisher warning. |
| macOS, Apple Silicon | `worktree-<version>-mac-arm64.dmg` | Developer ID signed and notarized. No Intel build. |
| Linux x86_64 | `worktree-<version>-linux-x86_64.AppImage` | Run `chmod +x` on it first. No ARM build. |

alpha.1 and alpha.2 are Windows only; alpha.3 and later cover all three.

## Verify a download

Each platform has a `SHA256SUMS-<platform>` file (`darwin-arm64`, `linux-x64`, `win32-x64`) and a `build-manifest-<platform>.json` naming the source revision. alpha.1 has a single `SHA256SUMS`.

```sh
gh release download v0.1.0-alpha.4 -R bycontinuity/worktree-releases \
  -p 'SHA256SUMS-linux-x64' -p '*.AppImage'
shasum -a 256 -c --ignore-missing SHA256SUMS-linux-x64
```

Prints `worktree-0.1.0-alpha.4-linux-x86_64.AppImage: OK` and exits 0. Swap the file names for your platform.

## Updating

Update metadata is the `alpha*.yml` files attached to each release (alpha.2 on). Settings > Updates > Check now forces a check. alpha.1 ships no update metadata; reinstall it by hand.

## Links

Support: support@tryworktree.com. Privacy: privacy@tryworktree.com. Site: https://tryworktree.com

`sh scripts/check-links.sh` checks that the links above still resolve.
