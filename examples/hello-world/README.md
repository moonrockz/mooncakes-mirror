# Hello World Example

A simple MoonBit project used as a test fixture for E2E testing the mooncakes-mirror registry.

## Usage

Write this to `$MOON_HOME/config.json` (default `~/.moon/config.json`), and make sure that
`MOONCAKES_REGISTRY` is not set:

```json
{
  "api": "https://mooncakes.io",
  "index": "https://github.com/moonrockz/mooncakes-index.git",
  "download": "https://download.mooncakes.io"
}
```

Then:

```bash
# Update moon index from the mirror
moon update

# Build the project
moon build

# Run the project
moon run src
```

## Purpose

This example is used by the E2E test workflow to verify that:
1. The mirror website (`stats.json`) is accessible
2. The mirror index can be shallow-cloned, and `moon update` works with it
3. The project builds and runs successfully
