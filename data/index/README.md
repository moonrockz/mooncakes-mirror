# MoonCakes Mirror - Registry Index

**Note:** The registry index data is not stored in this repository. It is the `main` branch of
[moonrockz/mooncakes-index](https://github.com/moonrockz/mooncakes-index).

The old `registry-index` branch of this repository is no longer updated.

## Architecture

- **`main` branch of this repository**: Contains source code (MoonBit site, workflows)
- **`main` branch of `moonrockz/mooncakes-index`**: A clone of the mooncakes.io index with upstream tracking

## How It Works

1. The `mirror.yml` workflow checks out `moonrockz/mooncakes-index`, merges the upstream index from mooncakes.io, writes `stats.json` and `yanked.json`, and pushes to `main`
2. Current `moon` shallow-clones `https://github.com/moonrockz/mooncakes-index.git` (GitHub serves it over Git smart HTTP)
3. The `pages.yml` workflow builds the website from `main` of this repository and takes `stats.json` and `yanked.json` from `mooncakes-index`
4. GitHub Pages serves the website. Its `/git/index` copy uses the dumb HTTP protocol and works only with `moon` releases from before 2026-08

This approach keeps a full history of the index and reduces reliance on upstream during deployment.

## Synchronization

The index is updated daily via GitHub Actions. See `.github/workflows/mirror.yml` for details.
