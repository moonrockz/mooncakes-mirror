# Main Application

Entry point for the MoonCakes Mirror Registry web application using the nested TEA (The Elm Architecture) pattern.

## Architecture

The application uses a nested TEA pattern where:
- The main module handles routing and wraps page messages
- Each page is an independent TEA module with its own Model, Msg, and view
- Messages are wrapped/unwrapped as they flow through the hierarchy

## Routing

Hash-based routing using URL fragments:

| Fragment | Page |
|----------|------|
| `#/` or `#/home` | Home (Dashboard) |
| `#/packages` | Packages List |
| `#/publishers` | Publishers Directory |

## Model

```moonbit
enum Page {
  Home(@home.Model)
  Packages(@packages.Model)
  Publishers(@publishers.Model)
}

struct Model {
  current_page : Page
}
```

## Messages

```moonbit
enum Msg {
  HomeMsg(@home.Msg)
  PackagesMsg(@packages.Msg)
  PublishersMsg(@publishers.Msg)
}
```

## Functions

### `parse_route(url) -> String`

Parses the URL fragment to determine which page to display.

### `initialize(url) -> (Cmd[Msg], Model)`

Initializes the application based on the current URL, delegating to the appropriate page's init function.

### `update(msg, model) -> (Cmd[Msg], Model)`

Routes messages to the appropriate page's update function, wrapping/unwrapping as needed.

### `view(model) -> Html[Msg]`

Renders the application layout with:
- Navigation bar (shared)
- Current page content
- Footer (shared)

## Entry Point

```moonbit
fn main {
  @tea.application(initialize~, update~, view~)
}
```
