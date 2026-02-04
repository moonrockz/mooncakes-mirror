///|
/// Shared UI components

using @html {div, span, text, a}

///|
/// Navigation bar component
pub fn[Msg] navbar(current_page : String) -> @html.Html[Msg] {
  let nav_link = fn(href : String, label : String, is_active : Bool) -> @html.Html[Msg] {
    let base_class = "px-4 py-2 rounded-lg text-sm font-medium transition-colors"
    let active_class = if is_active {
      "\{base_class} bg-indigo-100 text-indigo-700"
    } else {
      "\{base_class} text-slate-600 hover:text-indigo-600 hover:bg-slate-100"
    }
    a(href=href, class=active_class, [text(label)])
  }

  // Use div with role="navigation" since nav element not available
  div(class="bg-white border-b border-slate-200 sticky top-0 z-50", [
    div(class="max-w-6xl mx-auto px-4 sm:px-6", [
      div(class="flex items-center justify-between h-16", [
        // Logo
        a(href="#/home", class="flex items-center gap-2", [
          div(class="w-8 h-8 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-lg flex items-center justify-center", [
            span(class="text-white font-bold text-sm", [text("M")]),
          ]),
          span(class="font-semibold text-slate-800", [text("MoonCakes Mirror")]),
        ]),
        // Nav links
        div(class="flex items-center gap-2", [
          nav_link("#/home", "Home", current_page == "home"),
          nav_link("#/packages", "Packages", current_page == "packages"),
          nav_link("#/publishers", "Publishers", current_page == "publishers"),
        ]),
      ]),
    ]),
  ])
}

///|
/// Stat card component with improved styling
pub fn[Msg] stat_card(
  value : String,
  label : String,
  subtitle : String,
  color~ : String = "indigo"
) -> @html.Html[Msg] {
  let gradient = match color {
    "red" => "from-red-500 to-rose-600"
    "green" => "from-emerald-500 to-teal-600"
    "purple" => "from-purple-500 to-violet-600"
    _ => "from-indigo-500 to-blue-600"
  }

  // Get first character for the icon
  let first_char = if value.length() > 0 {
    let sb = StringBuilder::new()
    for c in value {
      sb.write_char(c)
      break
    }
    sb.to_string()
  } else {
    "#"
  }

  div(class="bg-white rounded-xl shadow-sm border border-slate-200 p-6 hover:shadow-md transition-shadow", [
    div(class="flex items-center gap-4", [
      div(class="w-12 h-12 bg-gradient-to-br \{gradient} rounded-xl flex items-center justify-center shadow-lg", [
        span(class="text-white text-xl font-bold", [text(first_char)]),
      ]),
      div([
        div(class="text-2xl font-bold text-slate-800", [text(value)]),
        div(class="text-sm text-slate-500", [text(label)]),
      ]),
    ]),
    if subtitle.length() > 0 {
      div(class="mt-3 pt-3 border-t border-slate-100", [
        span(class="text-xs text-slate-400", [text(subtitle)]),
      ])
    } else {
      text("")
    },
  ])
}

///|
/// Page header component
pub fn[Msg] page_header(title : String, subtitle : String) -> @html.Html[Msg] {
  div(class="mb-8", [
    div(class="text-3xl font-bold text-slate-800", [text(title)]),
    if subtitle.length() > 0 {
      div(class="text-slate-500 mt-2", [text(subtitle)])
    } else {
      text("")
    },
  ])
}

///|
/// Loading spinner component
pub fn[Msg] loading_spinner() -> @html.Html[Msg] {
  div(class="flex items-center justify-center py-12", [
    div(class="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600", []),
  ])
}

///|
/// Error alert component
pub fn[Msg] error_alert(message : String) -> @html.Html[Msg] {
  div(class="bg-red-50 border border-red-200 rounded-xl p-4 mb-6", [
    div(class="flex items-center gap-3", [
      span(class="text-red-500 text-xl", [text("!")]),
      div([
        div(class="font-medium text-red-800", [text("Error")]),
        div(class="text-sm text-red-600", [text(message)]),
      ]),
    ]),
  ])
}

///|
/// Footer component
pub fn[Msg] footer() -> @html.Html[Msg] {
  div(class="border-t border-slate-200 mt-12 py-8", [
    div(class="max-w-6xl mx-auto px-4 sm:px-6", [
      div(class="flex flex-col sm:flex-row items-center justify-between gap-4", [
        div(class="text-sm text-slate-500", [
          text("Built with "),
          a(href="https://mooncakes.io/docs/Yoorkin/rabbit-tea", class="text-indigo-600 hover:underline", [text("rabbit-tea")]),
          text(" and "),
          a(href="https://moonbitlang.com", class="text-indigo-600 hover:underline", [text("MoonBit")]),
        ]),
        div(class="flex items-center gap-4", [
          a(href="https://github.com/moonrockz/mooncakes-mirror", class="text-slate-400 hover:text-slate-600 transition-colors", [
            text("GitHub"),
          ]),
          a(href="https://mooncakes.io", class="text-slate-400 hover:text-slate-600 transition-colors", [
            text("mooncakes.io"),
          ]),
        ]),
      ]),
    ]),
  ])
}
