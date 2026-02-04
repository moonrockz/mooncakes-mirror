# MoonCakes Mirror - Registry Index

**Note:** The actual registry index data is stored on the `registry` branch, not on `main`.

## Architecture

- **`main` branch**: Contains source code (MoonBit site, workflows)
- **`registry` branch**: Contains the synced registry index and stats

## How It Works

1. The `mirror.yml` workflow clones the mooncakes.io index
2. It generates stats and pushes everything to the `registry` branch
3. The `pages.yml` workflow combines the built site from `main` with data from `registry`
4. GitHub Pages serves the combined result

## Synchronization

The index is updated daily via GitHub Actions. See `.github/workflows/mirror.yml` for details.
