# mooncakes-mirror

A mirror of the [mooncakes.io](https://mooncakes.io) package registry for MoonBit.

## What is this?

This repository serves as a mirror of the official MoonBit package registry (mooncakes.io). It uses [moonbit-registry-tools](https://github.com/moonrockz/moonbit-registry-tools) to automatically synchronize packages and provide an alternative registry source.

## Usage

To use this mirror registry in your MoonBit projects, set the `MOONCAKES_REGISTRY` environment variable:

```bash
export MOONCAKES_REGISTRY=https://moonrockz.github.io/mooncakes-mirror
```

Then use the Moon CLI as usual:

```bash
moon new my-project
cd my-project
moon add moonbitlang/core
moon build
```

## How it works

1. **Automated Mirroring**: A GitHub Actions workflow runs daily to sync packages from mooncakes.io
2. **Index Storage**: The package index is stored in the `data/index/` directory and committed to this repository
3. **GitHub Pages**: The index is served via GitHub Pages at `https://moonrockz.github.io/mooncakes-mirror`
4. **Package Downloads**: Package `.zip` files are proxied through to mooncakes.io (not stored in this repository)

## Manual Mirror

You can manually trigger a mirror operation:

1. Go to the [Actions tab](https://github.com/moonrockz/mooncakes-mirror/actions/workflows/mirror.yml)
2. Click "Run workflow"
3. Choose either:
   - Full mirror (all packages)
   - Pattern-based mirror (e.g., `moonbitlang/*`)
   - Default (mirrors moonbitlang packages)

## Configuration

The registry is configured via `registry.toml`. Key settings:

- **Source**: Mirrors from `https://mooncakes.io`
- **Data directory**: `./data/`
- **Base URL**: `https://moonrockz.github.io/mooncakes-mirror`

## Benefits of using a mirror

- **Reliability**: Alternative source if mooncakes.io is unavailable
- **Performance**: Potentially faster access depending on your location
- **Offline Development**: Can be cloned and used offline (with cached packages)
- **CI/CD**: Stable registry source for continuous integration pipelines

## Related Projects

- [moonbit-registry-tools](https://github.com/moonrockz/moonbit-registry-tools) - The tool used to create and maintain this mirror
- [MoonBit](https://www.moonbitlang.com/) - The MoonBit programming language
- [mooncakes.io](https://mooncakes.io) - The official MoonBit package registry

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
