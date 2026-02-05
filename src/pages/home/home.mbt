///|
/// Home Page - Dashboard with registry stats and info

using @html {div, span, text, h2, h3, p, a, ul, li, pre, code, node, attribute}
using @shared {icon, icon_styled}

///|
/// Home page model
pub struct Model {
  stats : @shared.Stats
  loading : Bool
  error : String?
} derive(Default)

///|
/// Home page messages
pub enum Msg {
  StatsLoaded(Result[String, String])
}

///|
/// Initialize the home page
pub fn page_init() -> (@tea.Cmd[Msg], Model) {
  let model : Model = {
    stats: @shared.Stats::default(),
    loading: true,
    error: None,
  }
  let cmd : @tea.Cmd[Msg] = @http.get("stats.json", expect=@http.Text(fn(r) { StatsLoaded(r) }))
  (cmd, model)
}

///|
/// Update the home page state
pub fn update(msg : Msg, model : Model) -> (@tea.Cmd[Msg], Model) {
  match msg {
    StatsLoaded(result) => {
      match result {
        Ok(json_str) => {
          let stats = @shared.parse_stats(json_str)
          (@tea.none(), { stats, loading: false, error: None })
        }
        Err(err) => (@tea.none(), { ..model, loading: false, error: Some(err) })
      }
    }
  }
}

///|
/// Stats overview section
fn stats_section(stats : @shared.Stats) -> @html.Html[Msg] {
  div(class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8", [
    @shared.stat_card(
      stats.total_packages.to_string(),
      "Total Packages",
      if stats.last_sync_packages > 0 { "+\{stats.last_sync_packages} last sync" } else { "" },
      color="indigo",
    ),
    @shared.stat_card(
      stats.total_owners.to_string(),
      "Publishers",
      if stats.last_sync_owners > 0 { "+\{stats.last_sync_owners} last sync" } else { "" },
      color="purple",
    ),
    @shared.stat_card(
      stats.yanked_count.to_string(),
      "Yanked Versions",
      "",
      color="red",
    ),
  ])
}

///|
/// Status card
fn status_card(stats : @shared.Stats) -> @html.Html[Msg] {
  let sync_text = if stats.last_sync.length() > 0 {
    stats.last_sync
  } else {
    "Loading..."
  }

  div(class="bg-white rounded-xl shadow-sm border border-slate-200 p-6 mb-8", [
    div(class="flex items-center justify-between mb-4", [
      h3(class="text-lg font-semibold text-slate-800 flex items-center gap-2", [
        icon_styled("fa-solid fa-signal", "text-indigo-500"),
        text("Mirror Status"),
      ]),
      div(class="flex items-center gap-2", [
        icon_styled("fa-solid fa-circle", "text-emerald-500 text-xs animate-pulse"),
        span(class="text-sm text-emerald-600 font-medium", [text("Active")]),
      ]),
    ]),
    div(class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm", [
      div(class="flex items-center gap-2", [
        icon_styled("fa-solid fa-arrow-right-from-bracket", "text-slate-400"),
        span(class="text-slate-500", [text("Source: ")]),
        a(href="https://mooncakes.io", class="text-indigo-600 hover:underline", [text("mooncakes.io")]),
      ]),
      div(class="flex items-center gap-2", [
        icon_styled("fa-solid fa-clock", "text-slate-400"),
        span(class="text-slate-500", [text("Last Sync: ")]),
        span(class="text-slate-700", [text(sync_text)]),
      ]),
    ]),
  ])
}

///|
/// Quick start section
fn quickstart_section() -> @html.Html[Msg] {
  div(class="bg-white rounded-xl shadow-sm border border-slate-200 p-6 mb-8", [
    h3(class="text-lg font-semibold text-slate-800 mb-4 flex items-center gap-2", [
      icon_styled("fa-solid fa-rocket", "text-indigo-500"),
      text("Quick Start"),
    ]),
    p(class="text-slate-600 mb-4", [
      text("Set the "),
      code(class="bg-slate-100 px-2 py-0.5 rounded text-sm font-mono text-indigo-600", [text("MOONCAKES_REGISTRY")]),
      text(" environment variable to use this mirror:"),
    ]),
    pre(class="bg-slate-900 text-slate-100 p-4 rounded-lg overflow-x-auto mb-4 text-sm", [
      code([text("export MOONCAKES_REGISTRY=https://moonrockz.github.io/mooncakes-mirror")]),
    ]),
    p(class="text-slate-600 mb-4", [text("Then use the Moon CLI as usual:")]),
    pre(class="bg-slate-900 text-slate-100 p-4 rounded-lg overflow-x-auto text-sm", [
      code([text("moon new my-project\ncd my-project\nmoon add moonbitlang/core\nmoon build")]),
    ]),
  ])
}

///|
/// Registry Tools callout section
fn registry_tools_section() -> @html.Html[Msg] {
  div(class="bg-gradient-to-r from-indigo-50 to-purple-50 rounded-xl border border-indigo-100 p-6 mb-8", [
    div(class="flex flex-col md:flex-row md:items-center md:justify-between gap-4", [
      div(class="flex-1", [
        div(class="flex items-center gap-3 mb-2", [
          node("img", [
            attribute("src", "https://moonrockz.github.io/moonbit-registry-tools/assets/Moonrocks-plain-flag.png"),
            attribute("alt", "moonrockz"),
            attribute("class", "w-10 h-10 rounded-lg"),
          ], []),
          h3(class="text-lg font-semibold text-slate-800", [text("Moonbit Registry Tools")]),
        ]),
        p(class="text-slate-600 mb-2", [
          text("A suite of command-line tools for working with the Moonbit package registry. Create mirrors, sync packages, and manage your own registry infrastructure."),
        ]),
        ul(class="text-sm text-slate-500 space-y-1", [
          li(class="flex items-center gap-2", [icon_styled("fa-solid fa-rotate", "text-indigo-400"), text("Sync packages from mooncakes.io")]),
          li(class="flex items-center gap-2", [icon_styled("fa-solid fa-list", "text-indigo-400"), text("Build complete registry indexes")]),
          li(class="flex items-center gap-2", [icon_styled("fa-solid fa-ban", "text-indigo-400"), text("Track yanked packages and versions")]),
        ]),
      ]),
      div(class="flex flex-col gap-2", [
        a(href="https://github.com/moonrockz/moonbit-registry-tools", class="inline-flex items-center justify-center gap-2 px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors font-medium text-sm", [
          icon("fa-brands fa-github"),
          text("View on GitHub"),
        ]),
        a(href="https://moonrockz.github.io/moonbit-registry-tools/", class="inline-flex items-center justify-center gap-2 px-4 py-2 bg-white text-indigo-600 border border-indigo-200 rounded-lg hover:bg-indigo-50 transition-colors font-medium text-sm", [
          icon("fa-solid fa-book"),
          text("Documentation"),
        ]),
      ]),
    ]),
  ])
}

///|
/// Features grid
fn features_section() -> @html.Html[Msg] {
  let feature_card = fn(icon_class : String, title : String, description : String) -> @html.Html[Msg] {
    div(class="bg-white rounded-xl shadow-sm border border-slate-200 p-6", [
      div(class="flex items-center gap-3 mb-2", [
        icon_styled(icon_class, "text-indigo-500 text-lg"),
        h3(class="font-semibold text-slate-800", [text(title)]),
      ]),
      p(class="text-sm text-slate-600", [text(description)]),
    ])
  }

  div(class="mb-8", [
    h2(class="text-xl font-semibold text-slate-800 mb-4 flex items-center gap-2", [
      icon_styled("fa-solid fa-star", "text-amber-500"),
      text("Features"),
    ]),
    div(class="grid grid-cols-1 md:grid-cols-2 gap-4", [
      feature_card("fa-solid fa-rotate", "Daily Sync", "Automatically synchronized with mooncakes.io every day at 2 AM UTC."),
      feature_card("fa-solid fa-database", "Full Index", "Complete package index with all metadata, versions, and checksums."),
      feature_card("fa-brands fa-git-alt", "Git Protocol", "Compatible Git dumb HTTP protocol for seamless integration."),
      feature_card("fa-solid fa-code-branch", "Open Source", "Fully open source and community-driven mirror solution."),
    ]),
  ])
}

///|
/// Self-hosting callout section
fn selfhost_callout_section() -> @html.Html[Msg] {
  div(class="bg-white rounded-xl shadow-sm border border-slate-200 p-6 mb-8", [
    div(class="flex flex-col md:flex-row md:items-center md:justify-between gap-4", [
      div(class="flex-1", [
        h3(class="text-lg font-semibold text-slate-800 mb-2 flex items-center gap-2", [
          icon_styled("fa-solid fa-server", "text-slate-600"),
          text("Host Your Own Mirror"),
        ]),
        p(class="text-slate-600", [
          text("Need a private mirror for your organization or want to run your own registry infrastructure? Our self-hosting guide walks you through setting up a complete mooncakes mirror using GitHub Pages or your own server."),
        ]),
      ]),
      a(href="#/selfhost", class="inline-flex items-center justify-center gap-2 px-4 py-2 bg-slate-800 text-white rounded-lg hover:bg-slate-900 transition-colors font-medium text-sm whitespace-nowrap", [
        icon("fa-solid fa-arrow-right"),
        text("Self-Hosting Guide"),
      ]),
    ]),
  ])
}

///|
/// Links section
fn links_section() -> @html.Html[Msg] {
  div(class="bg-white rounded-xl shadow-sm border border-slate-200 p-6", [
    h3(class="text-lg font-semibold text-slate-800 mb-4 flex items-center gap-2", [
      icon_styled("fa-solid fa-link", "text-indigo-500"),
      text("Resources"),
    ]),
    ul(class="space-y-4", [
      li([
        a(href="https://www.moonbitlang.com/", class="text-indigo-600 hover:underline flex items-center gap-2", [
          icon_styled("fa-solid fa-moon", "text-slate-400"),
          text("Moonbit Official Website"),
        ]),
      ]),
      li([
        a(href="https://mooncakes.io", class="text-indigo-600 hover:underline flex items-center gap-2", [
          icon_styled("fa-solid fa-cube", "text-slate-400"),
          text("Mooncakes Registry"),
        ]),
      ]),
      li(class="bg-indigo-50 -mx-2 px-2 py-2 rounded-lg", [
        a(href="https://github.com/moonrockz/moonbit-registry-tools", class="text-indigo-600 hover:underline flex items-center gap-2 font-medium", [
          icon_styled("fa-solid fa-gears", "text-indigo-400"),
          text("Moonbit Registry Tools"),
        ]),
        p(class="text-xs text-slate-500 mt-1 ml-6", [
          text("CLI tools for mirroring, syncing, and managing Moonbit registries"),
        ]),
      ]),
      li([
        a(href="https://github.com/moonrockz/mooncakes-mirror", class="text-indigo-600 hover:underline flex items-center gap-2", [
          icon_styled("fa-brands fa-github", "text-slate-400"),
          text("Mirror Repository"),
        ]),
      ]),
      li([
        a(href="#/selfhost", class="text-indigo-600 hover:underline flex items-center gap-2", [
          icon_styled("fa-solid fa-server", "text-slate-400"),
          text("Self-Hosting Guide"),
        ]),
      ]),
    ]),
  ])
}

///|
/// Render the home page view
pub fn view(model : Model) -> @html.Html[Msg] {
  div(class="max-w-6xl mx-auto px-4 sm:px-6 py-8", [
    // Header
    @shared.page_header("Dashboard", "Mooncakes Mirror Registry Status"),
    // Loading state
    if model.loading {
      @shared.loading_spinner()
    } else {
      text("")
    },
    // Error state
    match model.error {
      Some(err) => @shared.error_alert(err)
      None => text("")
    },
    // Main content (only show when not loading)
    if not(model.loading) {
      div([
        stats_section(model.stats),
        status_card(model.stats),
        quickstart_section(),
        registry_tools_section(),
        features_section(),
        selfhost_callout_section(),
        links_section(),
      ])
    } else {
      text("")
    },
  ])
}
