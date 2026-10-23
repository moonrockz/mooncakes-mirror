///|
/// Self-Hosting Guide Page

using @html {div, span, text, h2, h3, p, a, ul, li, pre, code, ol}
using @shared {icon, icon_styled}

///|
/// Self-host page model (static page, no state needed)
pub struct Model {
  _placeholder : Unit
} derive(Default)

///|
/// Self-host page messages
pub enum Msg {
  NoOp
}

///|
/// Initialize the self-host page
pub fn page_init() -> (@tea.Cmd[Msg], Model) {
  (@tea.none(), Model::default())
}

///|
/// Update (no-op for static page)
pub fn update(_msg : Msg, model : Model) -> (@tea.Cmd[Msg], Model) {
  (@tea.none(), model)
}

///|
/// Code block helper
fn code_block(content : String) -> @html.Html[Msg] {
  pre(class="bg-slate-900 text-slate-100 p-4 rounded-lg overflow-x-auto text-sm mb-4", [
    code([text(content)]),
  ])
}

///|
/// Section with title and icon
fn section(icon_class : String, title : String, children : Array[@html.Html[Msg]]) -> @html.Html[Msg] {
  div(class="mb-8", [
    h2(class="text-xl font-semibold text-slate-800 mb-4 pb-2 border-b border-slate-200 flex items-center gap-2", [
      icon_styled(icon_class, "text-indigo-500"),
      text(title),
    ]),
    div(children),
  ])
}

///|
/// Subsection with title
fn subsection(title : String, children : Array[@html.Html[Msg]]) -> @html.Html[Msg] {
  div(class="mb-6", [
    h3(class="text-lg font-medium text-slate-700 mb-3", [text(title)]),
    div(children),
  ])
}

///|
/// Info callout
fn info_callout(content : String) -> @html.Html[Msg] {
  div(class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-4", [
    div(class="flex items-start gap-3", [
      icon_styled("fa-solid fa-circle-info", "text-blue-500 text-lg"),
      p(class="text-sm text-blue-800", [text(content)]),
    ]),
  ])
}

///|
/// Warning callout
fn warning_callout(content : String) -> @html.Html[Msg] {
  div(class="bg-amber-50 border border-amber-200 rounded-lg p-4 mb-4", [
    div(class="flex items-start gap-3", [
      icon_styled("fa-solid fa-triangle-exclamation", "text-amber-500 text-lg"),
      p(class="text-sm text-amber-800", [text(content)]),
    ]),
  ])
}

///|
/// Overview section
fn overview_section() -> @html.Html[Msg] {
  section("fa-solid fa-book-open", "Overview", [
    p(class="text-slate-600 mb-4", [
      text("This guide walks you through setting up your own mooncakes mirror registry. A mirror allows you to:"),
    ]),
    ul(class="list-disc list-inside text-slate-600 space-y-2 mb-4", [
      li([text("Provide faster package downloads for your region or organization")]),
      li([text("Ensure package availability even if the main registry is down")]),
      li([text("Host private packages alongside public ones")]),
      li([text("Have full control over your dependency infrastructure")]),
    ]),
    info_callout("Current moon (from 2026-08) clones the registry index with git clone --depth 1 from a branch named main. A shallow clone needs the Git smart HTTP protocol. Static hosts such as GitHub Pages serve only the dumb HTTP protocol, so they cannot host an index that current moon can use."),
  ])
}

///|
/// Prerequisites section
fn prerequisites_section() -> @html.Html[Msg] {
  section("fa-solid fa-list-check", "Prerequisites", [
    ul(class="list-disc list-inside text-slate-600 space-y-2 mb-4", [
      li([
        text("Moonbit toolchain installed ("),
        a(href="https://www.moonbitlang.com/download/", class="text-indigo-600 hover:underline", [text("download")]),
        text(")"),
      ]),
      li([text("Git installed and configured (it includes git-http-backend, which the registry server uses for smart HTTP)")]),
      li([text("A server that can run moonbit-registry serve, or a GitHub account to host the index as a repository")]),
      li([text("Basic familiarity with command-line tools")]),
    ]),
  ])
}

///|
/// Client configuration section
fn client_config_section() -> @html.Html[Msg] {
  section("fa-solid fa-laptop-code", "Point moon at Your Mirror", [
    p(class="text-slate-600 mb-2", [
      text("Clients write $MOON_HOME/config.json (default ~/.moon/config.json). For this mirror, the file is:"),
    ]),
    code_block(
      "{\n  \"api\": \"https://mooncakes.io\",\n  \"index\": \"https://github.com/moonrockz/mooncakes-index.git\",\n  \"download\": \"https://download.mooncakes.io\"\n}",
    ),
    p(class="text-slate-600 mb-2", [
      text("For your own mirror, set index (and, if you serve package archives, api and download) to your server. Then run moon update."),
    ]),
    warning_callout("Do not set MOONCAKES_REGISTRY to a GitHub Pages URL. With moon from 2026-08 on, it makes moon shallow-clone <url>/git/index, and GitHub Pages cannot serve that."),
  ])
}

///|
/// Registry tools section
fn registry_tools_setup_section() -> @html.Html[Msg] {
  section("fa-solid fa-terminal", "Option 1: Serve a Registry with moonbit-registry-tools", [
    p(class="text-slate-600 mb-4", [
      text("This is the recommended way. From v0.3.0, moonbit-registry serve serves the index over Git smart HTTP by default, so current moon can shallow-clone it. It also serves the package archives that you mirror."),
    ]),
    subsection("Install Registry Tools", [
      code_block("mise use -g \"github:moonrockz/moonbit-registry-tools@latest\""),
      p(class="text-slate-600 mb-2", [
        text("Or download a binary from the "),
        a(href="https://github.com/moonrockz/moonbit-registry-tools/releases", class="text-indigo-600 hover:underline", [text("releases page")]),
        text("."),
      ]),
    ]),
    subsection("Initialize the Registry", [
      code_block("moonbit-registry init ./my-registry --name my-registry\ncd my-registry"),
    ]),
    subsection("Mirror Packages", [
      code_block("# Mirror some packages (and their dependencies)\nmoonbit-registry mirror \"moonbitlang/*\"\n\n# Or mirror the entire registry\nmoonbit-registry mirror --full"),
    ]),
    subsection("Start the Server", [
      code_block("moonbit-registry serve --host 0.0.0.0 --port 8080"),
      p(class="text-slate-600 mb-2", [
        text("Clients then use this config.json:"),
      ]),
      code_block(
        "{\n  \"api\": \"http://YOUR-SERVER:8080\",\n  \"index\": \"http://YOUR-SERVER:8080/git/index\",\n  \"download\": \"http://YOUR-SERVER:8080\"\n}",
      ),
    ]),
  ])
}

///|
/// GitHub-hosted index section
fn github_index_section() -> @html.Html[Msg] {
  section("fa-brands fa-github", "Option 2: Host the Index on GitHub", [
    p(class="text-slate-600 mb-4", [
      text("This is how this mirror works. GitHub serves a repository over smart HTTP, so the index can live in a repository whose default branch main is the index. Package archives still come from download.mooncakes.io."),
    ]),
    subsection("1. Create the Index Repository", [
      p(class="text-slate-600 mb-2", [
        text("Create a repository (for example YOUR-ORG/mooncakes-index) and push the upstream index to its main branch:"),
      ]),
      code_block("git clone https://mooncakes.io/git/index mooncakes-index\ncd mooncakes-index\ngit remote set-url origin git@github.com:YOUR-ORG/mooncakes-index.git\ngit push -u origin main"),
    ]),
    subsection("2. Fork the Mirror Repository", [
      p(class="text-slate-600 mb-2", [
        text("Fork "),
        a(href="https://github.com/moonrockz/mooncakes-mirror", class="text-indigo-600 hover:underline", [text("mooncakes-mirror")]),
        text(". In its workflows, replace moonrockz/mooncakes-index with your index repository."),
      ]),
    ]),
    subsection("3. Add a Deploy Key", [
      ol(class="list-decimal list-inside text-slate-600 space-y-2 mb-4", [
        li([text("Make an SSH key pair: ssh-keygen -t ed25519 -f deploy_key -N \"\"")]),
        li([text("Add deploy_key.pub to the index repository as a deploy key with write access")]),
        li([text("Add deploy_key to the fork as the Actions secret MOONCAKES_INDEX_DEPLOY_KEY")]),
      ]),
    ]),
    subsection("4. Enable GitHub Actions and Pages", [
      p(class="text-slate-600 mb-2", [
        text("The mirror workflow updates the index every day at 2 AM UTC. For the statistics website, go to Settings, then Pages, and select \"GitHub Actions\" as the source."),
      ]),
    ]),
  ])
}

///|
/// Automation section
fn automation_section() -> @html.Html[Msg] {
  section("fa-solid fa-clock-rotate-left", "Keeping the Mirror Up to Date", [
    p(class="text-slate-600 mb-4", [
      text("With moonbit-registry-tools, run the mirror command on a schedule on your server, for example with cron:"),
    ]),
    code_block("0 2 * * * cd /srv/my-registry && moonbit-registry mirror \"moonbitlang/*\""),
    warning_callout("Mirroring all packages can take significant time and storage. Consider mirroring only the packages your organization needs."),
  ])
}

///|
/// Configuration section
fn configuration_section() -> @html.Html[Msg] {
  section("fa-solid fa-sliders", "Configuration Options", [
    p(class="text-slate-600 mb-4", [
      text("Some useful options of moonbit-registry-tools:"),
    ]),
    div(class="overflow-x-auto", [
      div(class="bg-slate-50 rounded-lg p-4 mb-4", [
        div(class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm", [
          div([
            div(class="font-medium text-slate-700", [text("mirror --full")]),
            div(class="text-slate-500", [text("Mirror the entire registry")]),
          ]),
          div([
            div(class="font-medium text-slate-700", [text("mirror --strict")]),
            div(class="text-slate-500", [text("Mirror only exact pattern matches (no dependencies)")]),
          ]),
          div([
            div(class="font-medium text-slate-700", [text("serve --host / --port")]),
            div(class="text-slate-500", [text("Address of the registry server")]),
          ]),
          div([
            div(class="font-medium text-slate-700", [text("[server.smart_http]")]),
            div(class="text-slate-500", [text("Git smart HTTP for the index (on by default; current moon needs it)")]),
          ]),
          div([
            div(class="font-medium text-slate-700", [text("git.branch = \"main\"")]),
            div(class="text-slate-500", [text("moon fetches only the main branch of the index")]),
          ]),
        ]),
      ]),
    ]),
    p(class="text-slate-600 mb-2", [
      text("See the "),
      a(href="https://github.com/moonrockz/moonbit-registry-tools#usage", class="text-indigo-600 hover:underline", [text("full documentation")]),
      text(" for all available options."),
    ]),
  ])
}

///|
/// Resources section
fn resources_section() -> @html.Html[Msg] {
  section("fa-solid fa-link", "Resources", [
    ul(class="space-y-3", [
      li(class="flex items-center gap-2", [
        icon_styled("fa-brands fa-github", "text-slate-400"),
        a(href="https://github.com/moonrockz/moonbit-registry-tools", class="text-indigo-600 hover:underline font-medium", [
          text("Moonbit-registry-tools Repository"),
        ]),
        span(class="text-slate-500 text-sm", [text(" - CLI tools and documentation")]),
      ]),
      li(class="flex items-center gap-2", [
        icon_styled("fa-brands fa-github", "text-slate-400"),
        a(href="https://github.com/moonrockz/mooncakes-mirror", class="text-indigo-600 hover:underline font-medium", [
          text("mooncakes-mirror Template"),
        ]),
        span(class="text-slate-500 text-sm", [text(" - Ready-to-fork mirror template")]),
      ]),
      li(class="flex items-center gap-2", [
        icon_styled("fa-solid fa-cube", "text-slate-400"),
        a(href="https://mooncakes.io", class="text-indigo-600 hover:underline font-medium", [
          text("mooncakes.io"),
        ]),
        span(class="text-slate-500 text-sm", [text(" - Official Moonbit package registry")]),
      ]),
    ]),
  ])
}

///|
/// Render the self-host page view
pub fn view(_model : Model) -> @html.Html[Msg] {
  div(class="max-w-4xl mx-auto px-4 sm:px-6 py-8", [
    // Header
    @shared.page_header("Self-Hosting Guide", "Set up your own Mooncakes mirror registry"),
    // Content
    overview_section(),
    prerequisites_section(),
    client_config_section(),
    registry_tools_setup_section(),
    github_index_section(),
    automation_section(),
    configuration_section(),
    resources_section(),
  ])
}
