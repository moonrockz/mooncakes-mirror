# Hello World Example

A simple MoonBit project used as a test fixture for E2E testing the mooncakes-mirror registry.

## Dependencies

This project depends on:
- `moonbitlang/x` - MoonBit extended standard library

## Usage

```bash
# Set the registry to use the mirror
export MOONCAKES_REGISTRY=https://moonrockz.github.io/mooncakes-mirror

# Install dependencies
moon update

# Build the project
moon build

# Run the project
moon run src
```

## Purpose

This example is used by the E2E test workflow to verify that:
1. The mirror registry is accessible
2. Packages can be fetched from the mirror
3. Dependencies are resolved correctly
4. The project builds and runs successfully
