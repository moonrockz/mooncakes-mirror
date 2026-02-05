///|
/// Publishers Page - List all package publishers

using @html {div, span, text, h3, p, a, input}

///|
/// Publishers page model
pub struct Model {
  stats : @shared.Stats
  search_query : String
  loading : Bool
  error : String?
} derive(Default)

///|
/// Publishers page messages
pub enum Msg {
  StatsLoaded(Result[String, String])
  SearchChanged(String)
}

///|
/// Initialize the publishers page
pub fn page_init() -> (@tea.Cmd[Msg], Model) {
  let model : Model = {
    stats: @shared.Stats::default(),
    search_query: "",
    loading: true,
    error: None,
  }
  let cmd : @tea.Cmd[Msg] = @http.get("stats.json", expect=@http.Text(fn(r) { StatsLoaded(r) }))
  (cmd, model)
}

///|
/// Update the publishers page state
pub fn update(msg : Msg, model : Model) -> (@tea.Cmd[Msg], Model) {
  match msg {
    StatsLoaded(result) => {
      match result {
        Ok(json_str) => {
          let stats = @shared.parse_stats(json_str)
          (@tea.none(), { ..model, stats, loading: false, error: None })
        }
        Err(err) => (@tea.none(), { ..model, loading: false, error: Some(err) })
      }
    }
    SearchChanged(query) => {
      (@tea.none(), { ..model, search_query: query })
    }
  }
}

///|
/// Get first character of string safely
fn first_char(s : String) -> String {
  if s.length() > 0 {
    let sb = StringBuilder::new()
    for c in s {
      sb.write_char(c)
      break
    }
    sb.to_string()
  } else {
    "?"
  }
}

///|
/// Publisher card component
fn publisher_card(name : String, description : String) -> @html.Html[Msg] {
  a(href="https://mooncakes.io/docs/\{name}", class="block bg-white rounded-xl shadow-sm border border-slate-200 p-4 hover:shadow-md hover:border-indigo-200 transition-all", [
    div(class="flex items-center gap-3", [
      div(class="w-10 h-10 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-lg flex items-center justify-center", [
        span(class="text-white font-bold uppercase", [text(first_char(name))]),
      ]),
      div([
        div(class="font-medium text-slate-800", [text(name)]),
        div(class="text-sm text-slate-500", [text(description)]),
      ]),
    ]),
  ])
}

///|
/// Featured publishers section
fn featured_publishers() -> @html.Html[Msg] {
  div(class="mb-8", [
    h3(class="text-lg font-semibold text-slate-800 mb-4", [text("Featured Publishers")]),
    div(class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4", [
      publisher_card("moonbitlang", "Official Moonbit packages"),
      publisher_card("peter-jerry-ye", "Community contributor"),
      publisher_card("Yoorkin", "rabbit-tea framework author"),
      publisher_card("chawyehsu", "Moonbit tooling"),
      publisher_card("notch1p", "Community packages"),
      publisher_card("oboard", "Moonbit tools"),
    ]),
  ])
}

///|
/// Info section
fn publishers_info(stats : @shared.Stats) -> @html.Html[Msg] {
  div(class="bg-white rounded-xl shadow-sm border border-slate-200 p-6 mb-8", [
    div(class="grid grid-cols-1 sm:grid-cols-2 gap-6", [
      div([
        h3(class="text-lg font-semibold text-slate-800 mb-2", [text("About Publishers")]),
        p(class="text-sm text-slate-600", [
          text("Publishers are users who have published packages to the Mooncakes registry. This mirror tracks all "),
          span(class="font-semibold text-indigo-600", [text(stats.total_owners.to_string())]),
          text(" publishers and their "),
          span(class="font-semibold text-indigo-600", [text(stats.total_packages.to_string())]),
          text(" packages."),
        ]),
      ]),
      div([
        h3(class="text-lg font-semibold text-slate-800 mb-2", [text("Browse Packages")]),
        p(class="text-sm text-slate-600 mb-3", [
          text("To browse all packages from a publisher, visit their page on mooncakes.io."),
        ]),
        a(href="https://mooncakes.io", class="inline-flex items-center gap-2 bg-indigo-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-indigo-700 transition-colors", [
          text("Browse mooncakes.io"),
        ]),
      ]),
    ]),
  ])
}

///|
/// Search input
fn search_input(query : String) -> @html.Html[Msg] {
  div(class="mb-6", [
    div(class="relative", [
      input(
        input_type=@html.Text,
        placeholder="Search publishers...",
        value=query,
        class="w-full px-4 py-3 pl-10 bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent",
        input=fn(v) { SearchChanged(v) },
      ),
      div(class="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400", [
        span([text("S")]),
      ]),
    ]),
  ])
}

///|
/// Render the publishers page view
pub fn view(model : Model) -> @html.Html[Msg] {
  div(class="max-w-6xl mx-auto px-4 sm:px-6 py-8", [
    @shared.page_header("Publishers", "Package publishers in the Mooncakes registry"),
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
    // Main content
    if not(model.loading) {
      div([
        // Stats
        div(class="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-8", [
          @shared.stat_card(
            model.stats.total_owners.to_string(),
            "Total Publishers",
            "Users who have published packages",
            color="purple",
          ),
          @shared.stat_card(
            model.stats.total_packages.to_string(),
            "Total Packages",
            "Packages across all publishers",
            color="indigo",
          ),
        ]),
        publishers_info(model.stats),
        search_input(model.search_query),
        featured_publishers(),
      ])
    } else {
      text("")
    },
  ])
}
