# Shared Module

Common types, components, and utilities used across the MoonCakes Mirror Registry application.

## Types

### Stats

Registry statistics loaded from `stats.json`:

```moonbit
pub struct Stats {
  total_packages : Int      // Total number of packages in the registry
  total_owners : Int        // Total number of package publishers
  yanked_count : Int        // Number of yanked package versions
  last_sync_packages : Int  // Packages added in last sync
  last_sync_owners : Int    // Publishers added in last sync
  last_sync : String        // Timestamp of last sync
}
```

### YankedPackage

Information about a yanked package version:

```moonbit
pub struct YankedPackage {
  name : String     // Full package name (e.g., "moonbitlang/core")
  version : String  // Yanked version number
  reason : String   // Reason for yanking (if provided)
}
```

## Components

### Navigation

- `navbar(current_page)` - Top navigation bar with page links
- `footer()` - Site footer with links and attribution

### Cards

- `stat_card(value, title, subtitle, color~)` - Statistics display card
- `page_header(title, subtitle)` - Page header with title and description

### Feedback

- `loading_spinner()` - Loading indicator
- `error_alert(message)` - Error message display

## JSON Utilities

Helper functions for parsing JSON responses:

- `get_int(obj, key)` - Extract integer from JSON object
- `get_string(obj, key)` - Extract string from JSON object
- `get_bool(obj, key)` - Extract boolean from JSON object
- `get_string_array(obj, key)` - Extract string array from JSON object
- `parse_stats(json_str)` - Parse stats.json response
- `parse_yanked(json_str)` - Parse yanked.json response
