///|
/// Home Page - Dashboard with registry stats and info

using @html {div, span, text, h2, h3, p, a, ul, li, pre, code}

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
      h3(class="text-lg font-semibold text-slate-800", [text("Mirror Status")]),
      div(class="flex items-center gap-2", [
        div(class="w-2 h-2 bg-emerald-500 rounded-full animate-pulse", []),
        span(class="text-sm text-emerald-600 font-medium", [text("Active")]),
      ]),
    ]),
    div(class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm", [
      div([
        span(class="text-slate-500", [text("Source: ")]),
        a(href="https://mooncakes.io", class="text-indigo-600 hover:underline", [text("mooncakes.io")]),
      ]),
      div([
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
    h3(class="text-lg font-semibold text-slate-800 mb-4", [text("Quick Start")]),
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
/// Features grid
fn features_section() -> @html.Html[Msg] {
  let feature_card = fn(title : String, description : String) -> @html.Html[Msg] {
    div(class="bg-white rounded-xl shadow-sm border border-slate-200 p-6", [
      h3(class="font-semibold text-slate-800 mb-2", [text(title)]),
      p(class="text-sm text-slate-600", [text(description)]),
    ])
  }

  div(class="mb-8", [
    h2(class="text-xl font-semibold text-slate-800 mb-4", [text("Features")]),
    div(class="grid grid-cols-1 md:grid-cols-2 gap-4", [
      feature_card("Daily Sync", "Automatically synchronized with mooncakes.io every day at 2 AM UTC."),
      feature_card("Full Index", "Complete package index with all metadata, versions, and checksums."),
      feature_card("Git Protocol", "Compatible Git dumb HTTP protocol for seamless integration."),
      feature_card("Open Source", "Fully open source and community-driven mirror solution."),
    ]),
  ])
}

///|
/// Links section
fn links_section() -> @html.Html[Msg] {
  div(class="bg-white rounded-xl shadow-sm border border-slate-200 p-6", [
    h3(class="text-lg font-semibold text-slate-800 mb-4", [text("Resources")]),
    ul(class="space-y-3", [
      li([
        a(href="https://www.moonbitlang.com/", class="text-indigo-600 hover:underline flex items-center gap-2", [
          text("MoonBit Official Website"),
        ]),
      ]),
      li([
        a(href="https://mooncakes.io", class="text-indigo-600 hover:underline flex items-center gap-2", [
          text("MoonCakes Registry"),
        ]),
      ]),
      li([
        a(href="https://github.com/moonrockz/moonbit-registry-tools", class="text-indigo-600 hover:underline flex items-center gap-2", [
          text("MoonBit Registry Tools"),
        ]),
      ]),
      li([
        a(href="https://github.com/moonrockz/mooncakes-mirror", class="text-indigo-600 hover:underline flex items-center gap-2", [
          text("Mirror Repository"),
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
    @shared.page_header("Dashboard", "MoonCakes Mirror Registry Status"),
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
        features_section(),
        links_section(),
      ])
    } else {
      text("")
    },
  ])
}
