///|
/// MoonCakes Mirror Registry
/// Multi-page application using nested TEA pattern

using @html {div}

///|
/// Page enum for routing
enum Page {
  Home(@home.Model)
  Packages(@packages.Model)
  Publishers(@publishers.Model)
}

///|
/// Application state
struct Model {
  current_page : Page
}

///|
/// Application messages - wraps page messages
enum Msg {
  HomeMsg(@home.Msg)
  PackagesMsg(@packages.Msg)
  PublishersMsg(@publishers.Msg)
}

///|
/// Parse URL to determine the current page
fn parse_route(url : @url.Url) -> String {
  // Check the fragment (hash) for routing
  match url.fragment {
    Some(fragment) => {
      if fragment.has_prefix("/packages") {
        "packages"
      } else if fragment.has_prefix("/publishers") {
        "publishers"
      } else {
        "home"
      }
    }
    None => "home"
  }
}

///|
/// Initialize the application
fn initialize(url : @url.Url) -> (@tea.Cmd[Msg], Model) {
  let route = parse_route(url)

  match route {
    "packages" => {
      let (cmd, page_model) = @packages.page_init()
      let model : Model = { current_page: Packages(page_model) }
      (@tea.Cmd::map(cmd, fn(msg) { PackagesMsg(msg) }), model)
    }
    "publishers" => {
      let (cmd, page_model) = @publishers.page_init()
      let model : Model = { current_page: Publishers(page_model) }
      (@tea.Cmd::map(cmd, fn(msg) { PublishersMsg(msg) }), model)
    }
    _ => {
      let (cmd, page_model) = @home.page_init()
      let model : Model = { current_page: Home(page_model) }
      (@tea.Cmd::map(cmd, fn(msg) { HomeMsg(msg) }), model)
    }
  }
}

///|
/// Update function - routes messages to appropriate page
fn update(msg : Msg, model : Model) -> (@tea.Cmd[Msg], Model) {
  match msg {
    HomeMsg(page_msg) => {
      match model.current_page {
        Home(page_model) => {
          let (cmd, new_page_model) = @home.update(page_msg, page_model)
          (@tea.Cmd::map(cmd, fn(m) { HomeMsg(m) }), { current_page: Home(new_page_model) })
        }
        _ => (@tea.none(), model)
      }
    }
    PackagesMsg(page_msg) => {
      match model.current_page {
        Packages(page_model) => {
          let (cmd, new_page_model) = @packages.update(page_msg, page_model)
          (@tea.Cmd::map(cmd, fn(m) { PackagesMsg(m) }), { current_page: Packages(new_page_model) })
        }
        _ => (@tea.none(), model)
      }
    }
    PublishersMsg(page_msg) => {
      match model.current_page {
        Publishers(page_model) => {
          let (cmd, new_page_model) = @publishers.update(page_msg, page_model)
          (@tea.Cmd::map(cmd, fn(m) { PublishersMsg(m) }), { current_page: Publishers(new_page_model) })
        }
        _ => (@tea.none(), model)
      }
    }
  }
}

///|
/// Main view function
fn view(model : Model) -> @html.Html[Msg] {
  let current_page_name = match model.current_page {
    Home(_) => "home"
    Packages(_) => "packages"
    Publishers(_) => "publishers"
  }

  div(class="min-h-screen flex flex-col", [
    // Navigation
    @shared.navbar(current_page_name),
    // Page content
    div(class="flex-1", [
      match model.current_page {
        Home(page_model) => @html.Html::map(@home.view(page_model), fn(msg) { HomeMsg(msg) })
        Packages(page_model) => @html.Html::map(@packages.view(page_model), fn(msg) { PackagesMsg(msg) })
        Publishers(page_model) => @html.Html::map(@publishers.view(page_model), fn(msg) { PublishersMsg(msg) })
      },
    ]),
    // Footer
    @shared.footer(),
  ])
}

///|
/// Application entry point
fn main {
  @tea.application(initialize~, update~, view~)
}
