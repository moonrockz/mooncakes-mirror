///|
/// MoonCakes Mirror Registry Dashboard
/// Built with rabbit-tea (TEA architecture) and Tailwind CSS

// Import HTML elements using new syntax
using @html {div, span, text, h1, h2, p, a, ul, li, pre, code}

///|
/// Stats data from the registry
struct Stats {
  total_packages : Int
  total_owners : Int
  yanked_count : Int
  last_sync_packages : Int
  last_sync_owners : Int
  last_sync : String
} derive(Default)

///|
/// Application state
struct Model {
  stats : Stats
  loading : Bool
  error : String?
}

///|
/// Application messages
enum Msg {
  StatsLoaded(Result[String, String])
}

///|
/// Helper to get int from Json object
fn get_int(obj : Map[String, Json], key : String) -> Int {
  match obj.get(key) {
    Some(Number(n, ..)) => n.to_int()
    _ => 0
  }
}

///|
/// Helper to get string from Json object
fn get_string(obj : Map[String, Json], key : String) -> String {
  match obj.get(key) {
    Some(String(s)) => s
    _ => ""
  }
}

///|
/// Parse stats JSON and return Stats struct
fn parse_stats(json_str : String) -> Stats {
  let result = try {
    @json.parse(json_str[:])
  } catch {
    _ => return Stats::default()
  }
  match result {
    Object(obj) => {
      total_packages: get_int(obj, "totalPackages"),
      total_owners: get_int(obj, "totalOwners"),
      yanked_count: get_int(obj, "yankedCount"),
      last_sync_packages: get_int(obj, "lastSyncPackages"),
      last_sync_owners: get_int(obj, "lastSyncOwners"),
      last_sync: get_string(obj, "lastSync"),
    }
    _ => Stats::default()
  }
}

///|
/// Update function - handles all state transitions
fn update(msg : Msg, model : Model) -> (@tea.Cmd[Msg], Model) {
  match msg {
    StatsLoaded(result) => {
      match result {
        Ok(json_str) => {
          let stats = parse_stats(json_str)
          (@tea.none(), { stats, loading: false, error: None })
        }
        Err(err) => (@tea.none(), { ..model, loading: false, error: Some(err) })
      }
    }
  }
}

///|
/// Stat card component
fn stat_card(value : String, label : String, delta : String, is_yanked~ : Bool = false) -> @html.Html[Msg] {
  let value_color = if is_yanked { "text-red-500" } else { "text-blue-600" }
  let delta_color = if delta.has_prefix("+") { "text-green-500" } else { "text-gray-400" }

  div(class="bg-gray-50 p-4 rounded-lg text-center", [
    div(class="text-3xl font-bold \{value_color}", [text(value)]),
    div(class="text-sm text-gray-600 mt-1", [text(label)]),
    if delta.length() > 0 {
      span(class="text-xs \{delta_color} block mt-1", [text(delta)])
    } else {
      text("")
    },
  ])
}

///|
/// Info box component
fn info_box(model : Model) -> @html.Html[Msg] {
  let stats = model.stats
  let sync_text = if stats.last_sync.length() > 0 {
    "Last synced: \{stats.last_sync}"
  } else {
    "Loading sync info..."
  }

  div(class="bg-blue-50 border-l-4 border-blue-600 p-4 mb-6", [
    div(class="flex justify-between items-start", [
      div([
        p(class="font-semibold", [text("Status: "), span(class="text-green-600", [text("Active")])]),
        p([text("Source: "), a(href="https://mooncakes.io", class="text-blue-600 hover:underline", [text("mooncakes.io")])]),
        p([text("Repository: "), a(href="https://github.com/moonrockz/mooncakes-mirror", class="text-blue-600 hover:underline", [text("github.com/moonrockz/mooncakes-mirror")])]),
      ]),
    ]),
    // Stats grid
    div(class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4", [
      stat_card(
        stats.total_packages.to_string(),
        "Total Packages",
        if stats.last_sync_packages > 0 { "+\{stats.last_sync_packages} last sync" } else { "no change last sync" },
      ),
      stat_card(
        stats.total_owners.to_string(),
        "Total Publishers",
        if stats.last_sync_owners > 0 { "+\{stats.last_sync_owners} last sync" } else { "no change last sync" },
      ),
      stat_card(
        stats.yanked_count.to_string(),
        "Yanked Versions",
        "",
        is_yanked=true,
      ),
    ]),
    // Sync time
    p(class="text-sm text-gray-600 mt-4", [text(sync_text)]),
  ])
}

///|
/// Usage section
fn usage_section() -> @html.Html[Msg] {
  div(class="mb-6", [
    h2(class="text-xl font-semibold text-gray-800 mb-3", [text("Usage")]),
    p(class="mb-2", [
      text("To use this mirror registry with your MoonBit projects, set the "),
      code(class="bg-gray-100 px-1 rounded", [text("MOONCAKES_REGISTRY")]),
      text(" environment variable:"),
    ]),
    pre(class="bg-gray-100 p-3 rounded overflow-x-auto mb-4", [
      code([text("export MOONCAKES_REGISTRY=https://moonrockz.github.io/mooncakes-mirror")]),
    ]),
    p(class="mb-2", [text("Then use the Moon CLI as usual:")]),
    pre(class="bg-gray-100 p-3 rounded overflow-x-auto", [
      code([text("moon new my-project\ncd my-project\nmoon add moonbitlang/core\nmoon build")]),
    ]),
  ])
}

///|
/// About section
fn about_section() -> @html.Html[Msg] {
  div(class="mb-6", [
    h2(class="text-xl font-semibold text-gray-800 mb-3", [text("About")]),
    p(class="mb-2", [
      text("This is a mirror of the "),
      a(href="https://mooncakes.io", class="text-blue-600 hover:underline", [text("mooncakes.io")]),
      text(" registry for MoonBit packages. It is automatically synchronized daily and hosted on GitHub Pages."),
    ]),
    p([
      text("The mirror is created using "),
      a(href="https://github.com/moonrockz/moonbit-registry-tools", class="text-blue-600 hover:underline", [text("moonbit-registry-tools")]),
      text("."),
    ]),
  ])
}

///|
/// Endpoints section
fn endpoints_section() -> @html.Html[Msg] {
  div(class="mb-6", [
    h2(class="text-xl font-semibold text-gray-800 mb-3", [text("Endpoints")]),
    ul(class="list-disc list-inside space-y-1", [
      li([code(class="bg-gray-100 px-1 rounded", [text("/git/index")]), text(" - Git index repository")]),
      li([code(class="bg-gray-100 px-1 rounded", [text("/user/{username}/{package}/{version}.zip")]), text(" - Package downloads (proxied to mooncakes.io)")]),
    ]),
  ])
}

///|
/// Links section
fn links_section() -> @html.Html[Msg] {
  div(class="mb-6", [
    h2(class="text-xl font-semibold text-gray-800 mb-3", [text("Links")]),
    ul(class="list-disc list-inside space-y-1", [
      li([a(href="https://www.moonbitlang.com/", class="text-blue-600 hover:underline", [text("MoonBit Official Website")])]),
      li([a(href="https://mooncakes.io", class="text-blue-600 hover:underline", [text("MoonCakes Registry")])]),
      li([a(href="https://github.com/moonrockz/moonbit-registry-tools", class="text-blue-600 hover:underline", [text("MoonBit Registry Tools")])]),
      li([a(href="yanked.html", class="text-blue-600 hover:underline", [text("Yanked & Deprecated Packages")])]),
    ]),
  ])
}

///|
/// Main view function
fn view(model : Model) -> @html.Html[Msg] {
  div(class="max-w-3xl mx-auto px-5 py-12", [
    // Header
    h1(class="text-2xl font-bold text-gray-800 border-b-2 border-blue-600 pb-2 mb-6", [
      text("MoonCakes Mirror Registry"),
    ]),
    // Loading state
    if model.loading {
      div(class="text-gray-500 italic", [text("Loading stats...")])
    } else {
      text("")
    },
    // Error state
    match model.error {
      Some(err) => div(class="bg-red-50 border-l-4 border-red-500 p-4 mb-4", [
        text("Error loading stats: \{err}"),
      ])
      None => text("")
    },
    // Main content
    info_box(model),
    usage_section(),
    about_section(),
    endpoints_section(),
    links_section(),
    // Footer
    div(class="text-sm text-gray-500 text-center mt-8 pt-4 border-t", [
      text("Built with "),
      a(href="https://mooncakes.io/docs/Yoorkin/rabbit-tea", class="text-blue-600 hover:underline", [text("rabbit-tea")]),
      text(" and "),
      a(href="https://moonbitlang.com", class="text-blue-600 hover:underline", [text("MoonBit")]),
    ]),
  ])
}

///|
/// Initialize function for application with routing
fn initialize(_url : @url.Url) -> (@tea.Cmd[Msg], Model) {
  let model : Model = {
    stats: Stats::default(),
    loading: true,
    error: None,
  }
  // Return initial command to load stats
  let cmd : @tea.Cmd[Msg] = @http.get("stats.json", expect=@http.Text(fn(r) { StatsLoaded(r) }))
  (cmd, model)
}

///|
/// Application entry point
fn main {
  @tea.application(initialize~, update~, view~)
}
