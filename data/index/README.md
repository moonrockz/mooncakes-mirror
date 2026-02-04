# MoonCakes Mirror - Registry Index

This directory contains the Git-based package index for the mooncakes mirror registry.

The index is automatically synchronized from mooncakes.io by GitHub Actions workflows.

## Structure

- Each package has an entry in the index
- Package metadata is stored in Git commits
- The index follows the MoonBit registry index format

## Synchronization

The index is updated daily via GitHub Actions. See `.github/workflows/mirror.yml` for details.
