# Contributing to mooncakes-mirror

Thank you for your interest in contributing to the mooncakes-mirror project!

## Overview

This repository is an automated mirror of the mooncakes.io registry. Most operations are handled automatically by GitHub Actions, but this guide explains how to manage and maintain the mirror.

## How the Mirror Works

1. **GitHub Actions**: The `.github/workflows/mirror.yml` workflow runs daily (or on manual trigger) to sync packages from mooncakes.io
2. **Registry Tools**: Uses [moonbit-registry-tools](https://github.com/moonrockz/moonbit-registry-tools) to perform the mirroring
3. **Index Storage**: The package index is stored in `data/index/` and committed to the repository
4. **GitHub Pages**: The `.github/workflows/pages.yml` workflow deploys the index to GitHub Pages
5. **Package Storage**: Package `.zip` files are NOT stored in this repository; they are proxied from mooncakes.io

## Manual Operations

### Trigger a Manual Mirror

To manually trigger a mirror operation:

1. Go to [Actions → Mirror Mooncakes Registry](https://github.com/moonrockz/mooncakes-mirror/actions/workflows/mirror.yml)
2. Click "Run workflow"
3. Choose your options:
   - **Pattern**: Specify a package pattern (e.g., `moonbitlang/*` for all moonbitlang packages)
   - **Full mirror**: Check this to mirror ALL packages (may take a long time)
4. Click "Run workflow"

### Local Testing

To test the mirror setup locally:

```bash
# Clone the repository
git clone https://github.com/moonrockz/mooncakes-mirror.git
cd mooncakes-mirror

# Install moonbit-registry-tools (using mise)
mise use -g "github:moonrockz/moonbit-registry-tools@latest"

# Or download from releases:
# https://github.com/moonrockz/moonbit-registry-tools/releases

# Initialize the registry (first time only)
moonbit-registry init --name mooncakes-mirror

# Mirror specific packages
moonbit-registry mirror "moonbitlang/core"

# Or mirror all moonbitlang packages
moonbit-registry mirror "moonbitlang/*"

# Start the local server for testing
moonbit-registry serve --port 8080

# In another terminal, test with moon CLI
export MOONCAKES_REGISTRY=http://localhost:8080
moon new test-project
cd test-project
moon add moonbitlang/core
moon build
```

## Configuration

### Modifying registry.toml

The `registry.toml` file contains the registry configuration. Key sections:

- `[registry]`: Basic registry settings (name, data directory)
- `[[sources]]`: Upstream sources to mirror from (currently mooncakes.io)
- `[mirror]`: Mirror behavior (auto-sync, patterns)
- `[server]`: Server settings (host, port, base URL)
- `[git]`: Git integration settings

To modify the configuration:

1. Edit `registry.toml`
2. Commit and push changes
3. The next mirror run will use the updated configuration

### Changing Mirror Schedule

To change when automatic mirroring occurs:

1. Edit `.github/workflows/mirror.yml`
2. Modify the `schedule` cron expression:
   ```yaml
   schedule:
     - cron: '0 2 * * *'  # Daily at 2 AM UTC
   ```
3. Commit and push changes

Common cron patterns:
- `0 */6 * * *` - Every 6 hours
- `0 0 * * *` - Daily at midnight
- `0 0 * * 0` - Weekly on Sunday
- `0 0 1 * *` - Monthly on the 1st

### Changing Mirrored Packages

By default, the workflow mirrors all packages. To mirror only specific patterns:

1. Edit the workflow to specify default patterns
2. Or use the `packages` array in `registry.toml`:
   ```toml
   [mirror]
   packages = ["moonbitlang/*", "company/*"]
   ```

## Troubleshooting

### Mirror Workflow Fails

1. Check the [Actions tab](https://github.com/moonrockz/mooncakes-mirror/actions) for error logs
2. Common issues:
   - Network timeouts: Retry the workflow
   - Disk space: GitHub Actions has storage limits
   - Git conflicts: May need to manually resolve

### GitHub Pages Not Updating

1. Ensure the Pages workflow completed successfully
2. Check GitHub Pages settings in repository settings
3. Verify the `_site` directory is created correctly

### Package Not Found

If a package exists on mooncakes.io but not in the mirror:

1. Manually trigger a mirror for that package pattern
2. Wait for the workflow to complete
3. Check if the package was added to `data/index/`

## Maintenance Tasks

### Regular Maintenance

- Monitor workflow runs for failures
- Check disk usage (though packages aren't stored, the index can grow)
- Update moonbit-registry-tools version if needed

### Updating moonbit-registry-tools

The workflows use the latest version automatically via mise. To pin a specific version:

```yaml
- name: Install moonbit-registry-tools
  run: mise use -g "github:moonrockz/moonbit-registry-tools@v1.2.3"
```

## Getting Help

- **Issues**: Report problems in the [Issues](https://github.com/moonrockz/mooncakes-mirror/issues) tab
- **moonbit-registry-tools**: For tool-specific issues, see [moonbit-registry-tools](https://github.com/moonrockz/moonbit-registry-tools)
- **MoonBit**: For language/runtime issues, see [MoonBit docs](https://www.moonbitlang.com/docs/)

## Code of Conduct

Please be respectful and constructive in all interactions. This project follows the general principles of open source collaboration.
