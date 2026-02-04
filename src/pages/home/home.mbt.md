# Home Page

Dashboard page displaying registry statistics and quick start information.

## Model

```moonbit
pub struct Model {
  stats : @shared.Stats  // Registry statistics
  loading : Bool         // Loading state
  error : String?        // Error message if fetch failed
}
```

## Messages

```moonbit
pub enum Msg {
  StatsLoaded(Result[String, String])  // Stats fetch completed
}
```

## Sections

### Stats Overview

Displays three stat cards:
- **Total Packages** - Number of packages with last sync delta
- **Publishers** - Number of package owners with last sync delta
- **Yanked Versions** - Count of yanked package versions

### Mirror Status

Shows the current mirror status including:
- Source registry (mooncakes.io)
- Last synchronization timestamp
- Active status indicator

### Quick Start

Instructions for using the mirror:

```bash
export MOONCAKES_REGISTRY=https://moonrockz.github.io/mooncakes-mirror
moon new my-project
cd my-project
moon add moonbitlang/core
moon build
```

### Features

Grid of feature cards:
- Daily Sync - Automatic synchronization at 2 AM UTC
- Full Index - Complete package metadata and checksums
- Git Protocol - Compatible with Git dumb HTTP protocol
- Open Source - Community-driven mirror solution

### Resources

Links to:
- MoonBit Official Website
- MoonCakes Registry
- MoonBit Registry Tools
- Mirror Repository
