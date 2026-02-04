# Packages Page

Lists all packages in the registry with focus on yanked versions.

## Model

```moonbit
pub struct Model {
  yanked_packages : Array[@shared.YankedPackage]  // List of yanked packages
  search_query : String                            // Current search filter
  loading : Bool                                   // Loading state
  error : String?                                  // Error message if fetch failed
}
```

## Messages

```moonbit
pub enum Msg {
  YankedLoaded(Result[String, String])  // Yanked packages fetch completed
  SearchChanged(String)                  // Search input changed
}
```

## Features

### Statistics Cards

- **Total Packages** - From stats.json (placeholder until loaded)
- **Yanked Versions** - Count of yanked package versions

### Search

Filter yanked packages by name or version using the search input.

### Yanked Packages Table

Displays all yanked package versions with:
- Package name (linked to mooncakes.io)
- Version number
- Reason for yanking

## Data Source

Fetches from `yanked.json` which contains:

```json
{
  "yankedPackages": [
    {
      "name": "owner/package",
      "version": "1.0.0",
      "reason": "Security vulnerability"
    }
  ]
}
```
