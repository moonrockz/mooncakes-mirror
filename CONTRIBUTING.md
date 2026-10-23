# Contributing to mooncakes-mirror

Thank you for your interest in contributing to the mooncakes-mirror project!

## Overview

This repository is an automated mirror of the mooncakes.io registry index. GitHub Actions workflows do the mirror operations. This guide tells you how to manage and maintain the mirror.

## How the Mirror Works

1. **Mirror workflow**: The `.github/workflows/mirror.yml` workflow runs daily at 02:00 UTC, or when you start it manually. It fetches `main` from `https://mooncakes.io/git/index`, merges it into `main` of [moonrockz/mooncakes-index](https://github.com/moonrockz/mooncakes-index), and writes `stats.json` and `yanked.json`. Then it pushes to `moonrockz/mooncakes-index` with an SSH deploy key (see [Deploy Key](#deploy-key))
2. **Index serving**: GitHub serves `mooncakes-index` over Git smart HTTP. Current `moon` needs this, because it shallow-clones the `main` branch
3. **Pages workflow**: The `.github/workflows/pages.yml` workflow starts when the mirror workflow completes successfully, or when you start it manually. It builds the statistics website with Vite and `@rabbita/vite` from `main` of this repository. It copies `stats.json` and `yanked.json` from `mooncakes-index`. It also keeps a legacy `/git/index` copy that uses the dumb HTTP protocol. This copy works only with `moon` releases from before 2026-08
4. **E2E workflow**: The `.github/workflows/e2e.yml` workflow starts when the Pages workflow completes successfully, or when you start it manually. It writes `$MOON_HOME/config.json` with the index URL, runs `moon update`, builds and runs `examples/hello-world`, and adds a package from the index
5. **Manifests workflow**: The `.github/workflows/manifests.yml` workflow starts when the mirror workflow completes successfully, or when you start it manually. It adds archive manifests for new versions to `mooncakes-index` (see [Archive Manifests](#archive-manifests))
6. **Package storage**: The mirror does NOT store package `.zip` files. `moon` downloads them from `https://download.mooncakes.io`

The mirror, Pages and E2E workflows use only Git, shell commands, the MoonBit toolchain and Node.js. Only the manifests workflow uses [moonbit-registry-tools](https://github.com/moonrockz/moonbit-registry-tools). It runs the CLI from source with Bun.

## Manual Operations

### Trigger a Manual Mirror

To start a mirror operation manually:

1. Go to [Actions → Mirror Mooncakes Registry](https://github.com/moonrockz/mooncakes-mirror/actions/workflows/mirror.yml)
2. Click "Run workflow"
3. In the dialog, click "Run workflow" again

When the mirror workflow succeeds, the Pages workflow and then the E2E workflow start automatically.

### Use the Mirror Index Locally

Write this to `$MOON_HOME/config.json` (default `~/.moon/config.json`), and make sure that `MOONCAKES_REGISTRY` is not set:

```json
{
  "api": "https://mooncakes.io",
  "index": "https://github.com/moonrockz/mooncakes-index.git",
  "download": "https://download.mooncakes.io"
}
```

Then run `moon update` and build a project. Do not set `MOONCAKES_REGISTRY` to the GitHub Pages URL: from 2026-08, `moon` shallow-clones the index, and GitHub Pages serves only the dumb HTTP protocol, which cannot do shallow clones.

### Test a Self-Hosted Registry Locally

This test is optional. The workflows do not need it. It uses [moonbit-registry-tools](https://github.com/moonrockz/moonbit-registry-tools) v0.3.0 or later. From v0.3.0, `moonbit-registry serve` serves the index over Git smart HTTP by default, which current `moon` needs. Get the tool from the [releases page](https://github.com/moonrockz/moonbit-registry-tools/releases) and add it to your `PATH`.

```bash
# Make a local registry (first time only)
moonbit-registry init ./local-registry --name local-registry
cd local-registry

# Mirror some packages (and their dependencies)
moonbit-registry mirror "moonbitlang/core"

# Start the local server
moonbit-registry serve --port 8080

# In another terminal, point moon at the local server
cat > ~/.moon/config.json <<'EOF'
{
  "api": "http://localhost:8080",
  "index": "http://localhost:8080/git/index",
  "download": "http://localhost:8080"
}
EOF
moon update
moon new test-project
cd test-project
moon add moonbitlang/core
moon build
```

After the test, write the mirror configuration from [Use the Mirror Index Locally](#use-the-mirror-index-locally) back to `~/.moon/config.json`.

## Toolchain

### The Pin File

The `moonbit-version` file in the repository root pins the MoonBit toolchain. The current value is `0.10.15+943464bfa`.

The `moon` shim from [moonup](https://github.com/chawyehsu/moonup) reads this file. It looks in the current directory and then in each parent directory. If it finds no file, it uses the latest toolchain.

The pin exists because an unpinned latest toolchain broke the build two times:

- On 2026-02-11, MoonBit 0.8.1 broke the build.
- On 2026-10-21, moonc v0.10.17 removed `try?` and broke the build.

### Where the Version Is

The same version is in 4 places. All 4 must be the same:

| File | Place |
| --- | --- |
| `moonbit-version` | The full file |
| `.github/workflows/pages.yml` | `moonbit-version` input of `chawyehsu/setup-moonup` in the `deploy` job |
| `.github/workflows/e2e.yml` | `moonbit-version` input of `chawyehsu/setup-moonup` in the `test` job |
| `.github/workflows/e2e.yml` | `moonbit-version` input of `chawyehsu/setup-moonup` in the `test-matrix` job |

The `setup-moonup` action installs the toolchain. The `moon` shim then selects the toolchain from the `moonbit-version` file. If the two values are different, the shim tries to use a toolchain that the action did not install.

The E2E workflow copies `moonbit-version` into a temporary project outside the repository. Outside the repository, the shim cannot find the file in a parent directory.

### Update the Toolchain

1. Select the new version.
2. In one pull request, change the version in all 4 places in the table above.
3. Build the site locally from the repository root:
   ```bash
   moon version --all
   npm ci
   moon build --target js --release
   npm run build
   ```
   Make sure that `moon version --all` shows the new version. `moon build` shows MoonBit compiler errors. The Vite plugin only logs them and then fails on a missing `/main.js`.
4. Fix all compiler errors. If a vendored module fails, see [Vendored Dependencies](#vendored-dependencies).
5. Merge the pull request.
6. Start the Pages workflow manually. Make sure that the Pages run and the E2E run that follows it both pass. The Pages workflow always builds `main`, so a run before the merge does not test your change.

## Vendored Dependencies

The site uses two MoonBit modules that do not build with the current toolchain. The `vendor/` directory has patched copies of them:

| Module | Version | Upstream status |
| --- | --- | --- |
| `vendor/rabbit-tea` | `Yoorkin/rabbit-tea` 0.10.11 | Deprecated in favor of `moonbit-community/rabbita` |
| `vendor/js-ffi` | `rami3l/js-ffi` 0.4.0 | No newer release |

The root `moon.work` file adds `vendor/js-ffi` and `vendor/rabbit-tea` as workspace members. Thus `moon` uses these copies and not the registry versions. The build does not download MoonBit dependencies from the registry.

[`vendor/README.md`](vendor/README.md) lists each patch and the archive SHA-256 of each module. If you change a vendored file, add the change to that list.

The long-term fix is to port the site to [`moonbit-community/rabbita`](https://github.com/moonbit-community/rabbita). Then remove the `vendor/` directory and its `moon.work` entries.

## Operations

### Deploy Key

The mirror workflow pushes to `moonrockz/mooncakes-index` with an SSH deploy key:

- The private key is the Actions secret `MOONCAKES_INDEX_DEPLOY_KEY` in `moonrockz/mooncakes-mirror`.
- The public key is a deploy key with write access on `moonrockz/mooncakes-index`.

Only the mirror and manifests workflows use this secret. The Pages workflow reads the public `mooncakes-index` repository without a secret.

If the secret is missing, or if the key is not a deploy key with write access, the mirror job fails and the index does not update. A key that GitHub does not accept fails at the "Checkout mooncakes-index" step. Without the secret, `actions/checkout` uses the default token, which can read the public repository but cannot push to it, so the "Commit and push" step fails. The Pages and E2E workflows do not start after a failed mirror run.

To replace the key:

1. Make a key pair: `ssh-keygen -t ed25519 -f deploy_key -N ""`
2. In `moonrockz/mooncakes-index`, go to Settings, then Deploy keys. Add `deploy_key.pub` and select "Allow write access". Remove the old key.
3. In `moonrockz/mooncakes-mirror`, go to Settings, then Secrets and variables, then Actions. Set `MOONCAKES_INDEX_DEPLOY_KEY` to the contents of `deploy_key`.
4. Delete the local `deploy_key` and `deploy_key.pub` files.
5. Start the mirror workflow manually and make sure that it passes.

## Archive Manifests

### Purpose

An archive manifest records what a published package zip contains. There is one JSON line per version, in `manifests/user/<owner>/<pkg>.manifest` in `moonrockz/mooncakes-index`. Each line has the module name, the version, the checksum of the zip (the same as in the index), a content digest, and the entries in archive order with the SHA-256 and size of each entry.

The proxy of [moonbit-registry-tools](https://github.com/moonrockz/moonbit-registry-tools) uses these lines when `download.mooncakes.io` is not available. It rebuilds the zip from the GitHub source of the package and puts the entries in the published order. It serves the rebuilt zip only if its SHA-256 is equal to the index checksum. Without a manifest line, the proxy cannot do this check for that version.

`moon` reads only `user/<owner>/<pkg>.index`. It ignores `manifests/`. A local test with `moon update` and `moon add moonbitlang/x` against an index with `manifests/` passed.

### Workflow

The `.github/workflows/manifests.yml` workflow does these steps:

1. It checks out `moonrockz/mooncakes-index` with the deploy key, and `moonrockz/moonbit-registry-tools` at the ref in `REGISTRY_TOOLS_REF`.
2. It installs the Bun version from the `mise.toml` file of `moonbit-registry-tools`, and runs `bun install --frozen-lockfile`.
3. It writes a temporary `registry.toml` whose default source reads the index checkout and downloads from `https://download.mooncakes.io`.
4. It runs `moonbit-registry manifest build --index <checkout> --limit <n> --concurrency 8`. For each version without a line, the command downloads the zip, compares its SHA-256 with the index checksum, and writes the line. The zip stays in memory only. Nothing is cached on disk.
5. It commits only `manifests/` ("Add archive manifests: N versions"). Then it rebases on `origin/main` and pushes to `main`. If the push fails, it tries one more time.
6. It writes a summary: versions added, versions already present, failures, and versions still missing.

The workflow uses the concurrency group `mirror`, the same as the mirror workflow. Thus the two workflows never push at the same time. GitHub keeps at most one waiting run in a group: if a second run starts to wait, GitHub cancels the first waiting run. The command writes each line to disk immediately, and a later run adds only the lines that are missing. Thus you can stop a run, and you can run it again at any time.

To use a different version of `moonbit-registry-tools`, change `REGISTRY_TOOLS_REF` in the workflow file.

### Run a Backfill Manually

1. Go to [Actions → Archive Manifests](https://github.com/moonrockz/mooncakes-mirror/actions/workflows/manifests.yml)
2. Click "Run workflow"
3. Optional: set `limit` (default `10000`), the largest number of versions to add in this run
4. Optional: set `packages` to only do the packages that match one or more globs, separated by spaces (for example `moonbitlang/*`)
5. Click "Run workflow" again

Run it again until the summary shows 0 versions still missing. The daily run after the mirror workflow also continues the backfill, with the default limit.

To run the same command locally:

```bash
git clone https://github.com/moonrockz/mooncakes-index.git
git clone https://github.com/moonrockz/moonbit-registry-tools.git
cd moonbit-registry-tools
bun install --frozen-lockfile
bun run src/index.ts manifest build --index ../mooncakes-index --limit 200 --concurrency 8
```

Without `--dir`, the command uses the default source of the registry in the current directory (`https://download.mooncakes.io` if there is no `registry.toml`).

### How Long the Backfill Takes

The index has about 19500 versions. Their zips are about 16 GB in total (mean 881 KB, largest about 24 MB). A local test added about 14 versions per second (about 19 MB/s) with `--concurrency 8`. At this rate, a run with the default limit of 10000 takes about 12 minutes, and the full backfill takes two runs. A slower network on the runner makes a run longer. The build step stops after 75 minutes. The lines written before the stop are still committed, and the next run continues.

After the backfill, the daily run adds only the new versions of that day, so it is short.

### Failures

A failure is a version that got no line in this run. The summary lists each failed version with the cause. The next run tries it again. The run still commits the other lines, and it shows a warning, not an error.

- **Download error** (for example a 404, or a timeout): the zip was not available from `download.mooncakes.io`. A temporary error goes away in a later run. A version that always fails with 404 is not available upstream. The proxy cannot check a rebuild for that version.
- **Checksum mismatch**: the zip from `download.mooncakes.io` is not the zip that the index records. Do not add a line by hand. Report the version upstream.

The job fails when the build stops before the end, or when the push fails two times. If the push fails, make sure that the deploy key has write access (see [Deploy Key](#deploy-key)).

## Configuration

### registry.toml

The `registry.toml` file is a moonbit-registry-tools configuration. The workflows do not read it. Changes to it have no effect on the mirror, the website or the E2E test.

### Changing Mirror Schedule

To change when the automatic mirror runs:

1. Edit `.github/workflows/mirror.yml`
2. Change the `schedule` cron expression:
   ```yaml
   schedule:
     - cron: '0 2 * * *'
   ```
3. Commit and push the change

Common cron patterns (all times are UTC):
- `0 */6 * * *` - Every 6 hours
- `0 0 * * *` - Daily at midnight
- `0 0 * * 0` - Weekly on Sunday
- `0 0 1 * *` - Monthly on the 1st

### Mirrored Packages

The mirror workflow merges the full upstream index. It has no package filter. To mirror only some packages, use moonbit-registry-tools on your own server (see the Self-Hosting page of the website).

## Troubleshooting

### Mirror Workflow Fails

1. Look at the error log in the [Actions tab](https://github.com/moonrockz/mooncakes-mirror/actions)
2. Common issues:
   - Checkout fails, or push is rejected: Make sure that the `MOONCAKES_INDEX_DEPLOY_KEY` secret exists and that its public key is a deploy key with write access on `moonrockz/mooncakes-index` (see [Deploy Key](#deploy-key))
   - Network timeouts: Run the workflow again
   - Merge conflicts: Resolve the conflict manually in a clone of `moonrockz/mooncakes-index` and push to `main`

### GitHub Pages Not Updating

1. Make sure that the mirror workflow passed. The Pages workflow starts only after a successful mirror run
2. Make sure that the Pages workflow passed. If the "Check MoonBit sources" step fails, the toolchain or a vendored module is the usual cause (see [Toolchain](#toolchain))
3. In the repository settings, make sure that GitHub Pages uses "GitHub Actions" as the source
4. Look at the "Create pages directory structure" step log. It lists the files in `_site`

### Package Not Found

If a package exists on mooncakes.io but not in the mirror:

1. Start the mirror workflow manually
2. Wait for the workflow to complete
3. Look for the package in `user/` in [moonrockz/mooncakes-index](https://github.com/moonrockz/mooncakes-index)

## Maintenance Tasks

### Regular Maintenance

- Monitor the mirror, Pages and E2E workflow runs for failures
- Update the toolchain on purpose, with the procedure in [Update the Toolchain](#update-the-toolchain)
- Replace the deploy key if it is lost or exposed (see [Deploy Key](#deploy-key))

## Getting Help

- **Issues**: Report problems in the [Issues](https://github.com/moonrockz/mooncakes-mirror/issues) tab
- **moonbit-registry-tools**: For issues with self-hosting or local registry tests, see [moonbit-registry-tools](https://github.com/moonrockz/moonbit-registry-tools)
- **MoonBit**: For language/runtime issues, see [MoonBit docs](https://www.moonbitlang.com/docs/)

## Code of Conduct

Please be respectful and constructive in all interactions. This project follows the general principles of open source collaboration.
