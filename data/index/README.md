# MoonCakes Mirror - Registry Index

**Note:** The actual registry index data is stored on the `registry-index` branch, not on `main`.

## Architecture

- **`main` branch**: Contains source code (MoonBit site, workflows)
- **`registry-index` branch**: A clone of mooncakes.io index with upstream tracking

## How It Works

1. The `registry-index` branch is a direct clone of mooncakes.io index
2. The `mirror.yml` workflow pulls from upstream (mooncakes.io) and pushes to `registry-index`
3. The `pages.yml` workflow combines the built site from `main` with the index from `registry-index`
4. GitHub Pages serves the combined result

This approach keeps a full history of the index and reduces reliance on upstream during deployment.

## Synchronization

The index is updated daily via GitHub Actions. See `.github/workflows/mirror.yml` for details.
