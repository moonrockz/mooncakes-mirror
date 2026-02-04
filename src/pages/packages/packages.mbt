///|
/// Packages Page - List all packages with search and filtering

using @html {div, span, text, h3, p, a, input, table, thead, tbody, tr, th, td}

///|
/// Package info for display
pub struct PackageInfo {
  name : String
  owner : String
  latest_version : String
  license : String
  is_yanked : Bool
} derive(Default)

///|
/// Packages page model
pub struct Model {
  packages : Array[PackageInfo]
  yanked : Array[@shared.YankedPackage]
  search_query : String
  loading : Bool
  error : String?
} derive(Default)

///|
/// Packages page messages
pub enum Msg {
  YankedLoaded(Result[String, String])
  SearchChanged(String)
}

///|
/// Initialize the packages page
pub fn page_init() -> (@tea.Cmd[Msg], Model) {
  let model : Model = {
    packages: [],
    yanked: [],
    search_query: "",
    loading: true,
    error: None,
  }
  // Load yanked packages to show status
  let cmd : @tea.Cmd[Msg] = @http.get("yanked.json", expect=@http.Text(fn(r) { YankedLoaded(r) }))
  (cmd, model)
}

///|
/// Update the packages page state
pub fn update(msg : Msg, model : Model) -> (@tea.Cmd[Msg], Model) {
  match msg {
    YankedLoaded(result) => {
      match result {
        Ok(json_str) => {
          let yanked = @shared.parse_yanked(json_str)
          (@tea.none(), { ..model, yanked, loading: false, error: None })
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
/// Search input component
fn search_input(query : String) -> @html.Html[Msg] {
  div(class="mb-6", [
    div(class="relative", [
      input(
        input_type=@html.Text,
        placeholder="Search packages...",
        value=query,
        class="w-full px-4 py-3 pl-10 bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent",
        input=fn(v) { SearchChanged(v) },
      ),
      div(class="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400", [
        span([text("S")]), // Simple search icon placeholder
      ]),
    ]),
  ])
}

///|
/// Yanked packages table
fn yanked_table(yanked : Array[@shared.YankedPackage], query : String) -> @html.Html[Msg] {
  let filtered = if query.length() > 0 {
    let result : Array[@shared.YankedPackage] = []
    for pkg in yanked {
      if pkg.name.contains(query) || pkg.reason.contains(query) {
        result.push(pkg)
      }
    }
    result
  } else {
    yanked
  }

  if filtered.length() == 0 {
    div(class="bg-white rounded-xl shadow-sm border border-slate-200 p-8 text-center", [
      p(class="text-slate-500", [text("No yanked packages found.")]),
    ])
  } else {
    div(class="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden", [
      table(class="w-full", [
        thead(class="bg-slate-50", [
          tr([
            th(class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider", [text("Package")]),
            th(class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider", [text("Version")]),
            th(class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider", [text("Reason")]),
          ]),
        ]),
        tbody(class="divide-y divide-slate-200", {
          let rows : Array[@html.Html[Msg]] = []
          for pkg in filtered {
            rows.push(
              tr(class="hover:bg-slate-50", [
                td(class="px-6 py-4", [
                  a(href="https://mooncakes.io/docs/\{pkg.name}", class="text-indigo-600 hover:underline font-medium", [
                    text(pkg.name),
                  ]),
                ]),
                td(class="px-6 py-4 text-sm text-slate-600", [
                  span(class="bg-slate-100 px-2 py-1 rounded text-xs font-mono", [text(pkg.version)]),
                ]),
                td(class="px-6 py-4 text-sm text-slate-600", [
                  text(pkg.reason),
                ]),
              ])
            )
          }
          rows
        }),
      ]),
    ])
  }
}

///|
/// Info about the packages page
fn packages_info() -> @html.Html[Msg] {
  div(class="bg-indigo-50 border border-indigo-200 rounded-xl p-4 mb-6", [
    p(class="text-sm text-indigo-800", [
      text("This page shows yanked and deprecated packages. The full package index is available via the "),
      a(href="/mooncakes-mirror/git/index", class="text-indigo-600 hover:underline font-medium", [text("Git index")]),
      text(". You can also browse packages on "),
      a(href="https://mooncakes.io", class="text-indigo-600 hover:underline font-medium", [text("mooncakes.io")]),
      text("."),
    ]),
  ])
}

///|
/// Render the packages page view
pub fn view(model : Model) -> @html.Html[Msg] {
  div(class="max-w-6xl mx-auto px-4 sm:px-6 py-8", [
    @shared.page_header("Packages", "Yanked and deprecated packages in the mirror"),
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
        packages_info(),
        // Stats
        div(class="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6", [
          @shared.stat_card(
            model.yanked.length().to_string(),
            "Yanked Packages",
            "Versions that have been yanked or deprecated",
            color="red",
          ),
        ]),
        // Search
        search_input(model.search_query),
        // Table
        h3(class="text-lg font-semibold text-slate-800 mb-4", [text("Yanked & Deprecated Versions")]),
        yanked_table(model.yanked, model.search_query),
      ])
    } else {
      text("")
    },
  ])
}
