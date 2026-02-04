# Publishers Page

Directory of package publishers in the MoonCakes registry.

## Model

```moonbit
pub struct Model {
  stats : @shared.Stats  // Registry statistics
  search_query : String  // Current search filter
  loading : Bool         // Loading state
  error : String?        // Error message if fetch failed
}
```

## Messages

```moonbit
pub enum Msg {
  StatsLoaded(Result[String, String])  // Stats fetch completed
  SearchChanged(String)                 // Search input changed
}
```

## Sections

### Statistics

- **Total Publishers** - Number of users who have published packages
- **Total Packages** - Packages across all publishers

### About Publishers

Information about what publishers are and how they relate to packages.

### Featured Publishers

Highlighted community members:
- **moonbitlang** - Official MoonBit packages
- **peter-jerry-ye** - Community contributor
- **Yoorkin** - rabbit-tea framework author
- **chawyehsu** - MoonBit tooling
- **notch1p** - Community packages
- **oboard** - MoonBit tools

### Publisher Cards

Each card displays:
- Avatar with first letter of username
- Publisher name
- Brief description
- Link to mooncakes.io profile

## Search

Filter publishers by name using the search input (placeholder for future implementation with full publisher list).
