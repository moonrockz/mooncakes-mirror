# mooncakes-mirror

A mirror of the [mooncakes.io](https://mooncakes.io) package registry for MoonBit.

## What is this?

This repository serves as a mirror of the official MoonBit package registry (mooncakes.io). GitHub Actions workflows synchronize the index with Git every day. The workflows do not use [moonbit-registry-tools](https://github.com/moonrockz/moonbit-registry-tools).

## Usage

The mirrored index is the `main` branch of
[moonrockz/mooncakes-index](https://github.com/moonrockz/mooncakes-index).
To use it, write this to `$MOON_HOME/config.json` (default `~/.moon/config.json`):

```json
{
  "api": "https://mooncakes.io",
  "index": "https://github.com/moonrockz/mooncakes-index.git",
  "download": "https://download.mooncakes.io"
}
```

Then make sure that `MOONCAKES_REGISTRY` is not set, and use the Moon CLI as usual:

```bash
moon new my-project
cd my-project
moon add moonbitlang/core
moon build
```

Only the index is mirrored. Package archives still come from `download.mooncakes.io`.

> [!IMPORTANT]
> Do not set `MOONCAKES_REGISTRY=https://moonrockz.github.io/mooncakes-mirror`.
> From 2026-08, `moon` clones the index with `git clone --depth 1` from a branch named `main`.
> A shallow clone needs the Git smart HTTP protocol. GitHub Pages serves only the dumb HTTP
> protocol, so `moon update` fails with *"dumb http transport does not support shallow
> capabilities"*. The `/git/index` copy on the website is kept only for older `moon` releases.

## How it works

1. **Daily Mirroring**: The `mirror.yml` workflow runs every day at 02:00 UTC (or manually). It merges the upstream index from `https://mooncakes.io/git/index`, writes `stats.json` and `yanked.json`, and pushes to the `main` branch of [moonrockz/mooncakes-index](https://github.com/moonrockz/mooncakes-index) with a deploy key (repository secret `MOONCAKES_INDEX_DEPLOY_KEY`)
2. **Index Serving**: GitHub serves the index repository over smart HTTP, so `moon` can shallow-clone it
3. **GitHub Pages**: After a successful mirror run, the `pages.yml` workflow builds the statistics website at `https://moonrockz.github.io/mooncakes-mirror` from the index data
4. **E2E Test**: After a successful Pages run, the `e2e.yml` workflow runs `moon update` against the index and builds an example project
5. **Package Downloads**: Package `.zip` files are not mirrored. `moon` gets them from `https://download.mooncakes.io`
6. **Archive Manifests**: After a successful mirror run, the `manifests.yml` workflow adds a manifest line for each new version to `manifests/` in the index. The moonbit-registry-tools proxy uses it to check zips that it rebuilds from GitHub. `moon` ignores it. See [CONTRIBUTING.md](CONTRIBUTING.md#archive-manifests)

## Manual Mirror

You can also start a mirror operation manually:

1. Go to the [Actions tab](https://github.com/moonrockz/mooncakes-mirror/actions/workflows/mirror.yml)
2. Click "Run workflow"

## Development

The website is a MoonBit app that Vite builds with `@rabbita/vite`. The `moonbit-version` file pins the MoonBit toolchain, and `vendor/` has patched copies of two MoonBit dependencies. To build the site locally:

```bash
npm ci
moon build --target js --release
npm run build
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the toolchain update procedure, the vendored dependencies and the deploy key.

The `registry.toml` file is a moonbit-registry-tools configuration for local tests. The workflows do not read it.

## Self-hosting

To host your own registry or mirror, use [moonbit-registry-tools](https://github.com/moonrockz/moonbit-registry-tools)
(`moonbit-registry serve`). From v0.3.0 it serves the index over Git smart HTTP by default, which current
`moon` needs. A static host such as GitHub Pages cannot serve an index that current `moon` can use.

## Benefits of using a mirror

- **Reliability**: The index stays available if the mooncakes.io git index is unavailable (package downloads still use `download.mooncakes.io`)
- **Performance**: Potentially faster access depending on your location
- **Offline Development**: Can be cloned and used offline (with cached packages)
- **CI/CD**: Stable registry source for continuous integration pipelines

## Related Projects

- [moonbit-registry-tools](https://github.com/moonrockz/moonbit-registry-tools) - Tools to host your own MoonBit registry or mirror
- [MoonBit](https://www.moonbitlang.com/) - The MoonBit programming language
- [mooncakes.io](https://mooncakes.io) - The official MoonBit package registry

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
