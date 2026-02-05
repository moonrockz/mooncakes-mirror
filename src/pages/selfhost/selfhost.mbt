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
    info_callout("This mirror uses the moonbit-registry-tools CLI to sync packages from mooncakes.io and serve them via GitHub Pages or any static file host."),
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
      li([text("Git installed and configured")]),
      li([text("GitHub account (for GitHub Pages hosting) or another static file host")]),
      li([text("Basic familiarity with command-line tools")]),
    ]),
  ])
}

///|
/// Quick start section
fn quickstart_section() -> @html.Html[Msg] {
  section("fa-solid fa-rocket", "Quick Start", [
    p(class="text-slate-600 mb-4", [
      text("The fastest way to get started is to fork our template repository and enable GitHub Actions:"),
    ]),
    subsection("1. Fork the Template", [
      p(class="text-slate-600 mb-2", [
        text("Fork the "),
        a(href="https://github.com/moonrockz/mooncakes-mirror", class="text-indigo-600 hover:underline", [text("mooncakes-mirror")]),
        text(" repository to your GitHub account."),
      ]),
    ]),
    subsection("2. Enable GitHub Pages", [
      ol(class="list-decimal list-inside text-slate-600 space-y-2 mb-4", [
        li([text("Go to your forked repository's Settings")]),
        li([text("Navigate to Pages in the sidebar")]),
        li([text("Under \"Build and deployment\", select \"GitHub Actions\" as the source")]),
      ]),
    ]),
    subsection("3. Enable GitHub Actions", [
      p(class="text-slate-600 mb-2", [
        text("The repository includes a workflow that automatically syncs packages daily. Enable it in the Actions tab of your repository."),
      ]),
    ]),
    subsection("4. Configure Your Mirror URL", [
      p(class="text-slate-600 mb-2", [
        text("Once deployed, your mirror will be available at:"),
      ]),
      code_block("https://YOUR-USERNAME.github.io/mooncakes-mirror"),
      p(class="text-slate-600 mb-2", [
        text("Users can point to your mirror by setting the environment variable:"),
      ]),
      code_block("export MOONCAKES_REGISTRY=https://YOUR-USERNAME.github.io/mooncakes-mirror"),
    ]),
  ])
}

///|
/// Manual setup section
fn manual_setup_section() -> @html.Html[Msg] {
  section("fa-solid fa-terminal", "Manual Setup with Registry Tools", [
    p(class="text-slate-600 mb-4", [
      text("For more control, you can set up a mirror manually using the moonbit-registry-tools CLI."),
    ]),
    subsection("Install Registry Tools", [
      code_block("moon add moonrockz/moonbit-registry-tools"),
      p(class="text-slate-600 mb-2", [
        text("Or clone and build from source:"),
      ]),
      code_block("git clone https://github.com/moonrockz/moonbit-registry-tools\ncd moonbit-registry-tools\nmoon build"),
    ]),
    subsection("Initialize Mirror Directory", [
      p(class="text-slate-600 mb-2", [
        text("Create a directory structure for your mirror:"),
      ]),
      code_block("mkdir -p my-mirror\ncd my-mirror\ngit init"),
    ]),
    subsection("Sync Packages", [
      p(class="text-slate-600 mb-2", [
        text("Run the sync command to download packages from mooncakes.io:"),
      ]),
      code_block("moonbit-registry-tools sync --output ./registry"),
      p(class="text-slate-600 mb-2", [
        text("This will download all package metadata and create the registry index."),
      ]),
    ]),
    subsection("Generate Index Files", [
      p(class="text-slate-600 mb-2", [
        text("Build the registry index for the Moon CLI to consume:"),
      ]),
      code_block("moonbit-registry-tools index --input ./registry --output ./public"),
    ]),
    subsection("Deploy", [
      p(class="text-slate-600 mb-2", [
        text("Deploy the contents of the public directory to any static file host (GitHub Pages, Netlify, Vercel, nginx, etc.)."),
      ]),
    ]),
  ])
}

///|
/// Automation section
fn automation_section() -> @html.Html[Msg] {
  section("fa-solid fa-clock-rotate-left", "Automating Updates", [
    p(class="text-slate-600 mb-4", [
      text("To keep your mirror in sync with mooncakes.io, set up automated syncing."),
    ]),
    subsection("GitHub Actions Example", [
      p(class="text-slate-600 mb-2", [
        text("Create a workflow file at .github/workflows/sync.yml:"),
      ]),
      code_block("name: Sync Registry\n\non:\n  schedule:\n    - cron: '0 2 * * *'  # Daily at 2 AM UTC\n  workflow_dispatch:  # Manual trigger\n\njobs:\n  sync:\n    runs-on: ubuntu-latest\n    steps:\n      - uses: actions/checkout@v4\n      - name: Setup moonbit\n        uses: moonbitlang/setup-moonbit@v1\n      - name: Sync packages\n        run: |\n          moon run moonrockz/moonbit-registry-tools -- sync\n      - name: Deploy to GitHub Pages\n        uses: peaceiris/actions-gh-pages@v3\n        with:\n          github_token: ${{ secrets.GITHUB_TOKEN }}\n          publish_dir: ./public"),
    ]),
    warning_callout("Syncing all packages can take significant time and storage. Consider syncing only the packages your organization needs for a more efficient mirror."),
  ])
}

///|
/// Configuration section
fn configuration_section() -> @html.Html[Msg] {
  section("fa-solid fa-sliders", "Configuration Options", [
    p(class="text-slate-600 mb-4", [
      text("The registry tools support various configuration options:"),
    ]),
    div(class="overflow-x-auto", [
      div(class="bg-slate-50 rounded-lg p-4 mb-4", [
        div(class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm", [
          div([
            div(class="font-medium text-slate-700", [text("--packages")]),
            div(class="text-slate-500", [text("Sync only specific packages")]),
          ]),
          div([
            div(class="font-medium text-slate-700", [text("--exclude-yanked")]),
            div(class="text-slate-500", [text("Skip yanked package versions")]),
          ]),
          div([
            div(class="font-medium text-slate-700", [text("--since")]),
            div(class="text-slate-500", [text("Sync packages updated after date")]),
          ]),
          div([
            div(class="font-medium text-slate-700", [text("--concurrency")]),
            div(class="text-slate-500", [text("Number of parallel downloads")]),
          ]),
        ]),
      ]),
    ]),
    p(class="text-slate-600 mb-2", [
      text("See the "),
      a(href="https://github.com/moonrockz/moonbit-registry-tools#configuration", class="text-indigo-600 hover:underline", [text("full documentation")]),
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
    quickstart_section(),
    manual_setup_section(),
    automation_section(),
    configuration_section(),
    resources_section(),
  ])
}
