defmodule Presenter.Router do
  use Presenter.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :secure do
    plug :accepts, ["html"]
    plug BasicAuth, use_config: {:presenter, :pass}
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin_layout do
    plug :put_layout, {Presenter.LayoutView, :admin}
  end

  pipeline :present_layout do
    plug :put_layout, {Presenter.LayoutView, :presenter}
  end

  scope "/", Presenter do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/present", Presenter do
    pipe_through [:secure, :present_layout]
    get "/", PageController, :present

    resources "/", PageController
  end

  scope "/prayers", Presenter do
    pipe_through [:secure, :admin_layout]

    get "/reboot", PrayerController, :reboot
    get "/confirm", PrayerController, :confirm
    get "/shutdown", PrayerController, :shutdown
    get "/confirmshutdown", PrayerController, :confirmshutdown

    get "/github", PrayerController, :github
    resources "/", PrayerController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Presenter do
  #   pipe_through :api
  # end
end
